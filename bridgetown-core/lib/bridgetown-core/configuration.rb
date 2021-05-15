# frozen_string_literal: true

module Bridgetown
  # Holds the processed configuration loaded from the YAML config file.
  #
  # @todo refactor this whole object! Already had to fix obscure
  #   bugs just making minor changes, and all the indirection is
  #   quite hard to decipher. -JW
  class Configuration < HashWithDotAccess::Hash
    # Default options. Overridden by values in bridgetown.config.yml.
    # Strings rather than symbols are used for compatibility with YAML.
    DEFAULTS = {
      # Where things are
      "root_dir"             => Dir.pwd,
      "plugins_dir"          => "plugins",
      "source"               => File.join(Dir.pwd, "src"),
      "destination"          => File.join(Dir.pwd, "output"),
      "collections_dir"      => "",
      "cache_dir"            => ".bridgetown-cache",
      "layouts_dir"          => "_layouts",
      "data_dir"             => "_data",
      "components_dir"       => "_components",
      "includes_dir"         => "_includes",
      "partials_dir"         => "_partials",
      "collections"          => {},
      "taxonomies"           => {
        category: { key: "categories", title: "Category" }, tag: { key: "tags", title: "Tag" },
      },

      # Handling Reading
      "include"              => [".htaccess", "_redirects", ".well-known"],
      "exclude"              => [],
      "keep_files"           => [".git", ".svn", "_bridgetown"],
      "encoding"             => "utf-8",
      "markdown_ext"         => "markdown,mkdown,mkdn,mkd,md",
      "strict_front_matter"  => false,
      "slugify_categories"   => true,
      "slugify_mode"         => "pretty",

      # Filtering Content
      "limit_posts"          => 0,
      "future"               => false,
      "unpublished"          => false,
      "ruby_in_front_matter" => true,

      # Conversion
      "markdown"             => "kramdown",
      "highlighter"          => "rouge",
      "lsi"                  => false,
      "excerpt_separator"    => "\n\n",
      "incremental"          => false,

      # Serving
      "detach"               => false, # default to not detaching the server
      "port"                 => "4000",
      "host"                 => "127.0.0.1",
      "baseurl"              => nil, # this mounts at /, i.e. no subdirectory
      "show_dir_listing"     => false,

      # Output Configuration
      "available_locales"    => ["en"],
      "default_locale"       => "en",
      "permalink"            => nil, # default is set according to content engine
      "timezone"             => nil, # use the local timezone

      "quiet"                => false,
      "verbose"              => false,
      "defaults"             => [],

      "liquid"               => {
        "error_mode"       => "warn",
        "strict_filters"   => false,
        "strict_variables" => false,
      },

      "kramdown"             => {
        "auto_ids"                => true,
        "toc_levels"              => (1..6).to_a,
        "entity_output"           => "as_char",
        "smart_quotes"            => "lsquo,rsquo,ldquo,rdquo",
        "input"                   => "GFM",
        "hard_wrap"               => false,
        "guess_lang"              => true,
        "footnote_nr"             => 1,
        "show_warnings"           => false,
        "include_extraction_tags" => false,
      },
    }.each_with_object(Configuration.new) { |(k, v), hsh| hsh[k] = v.freeze }.freeze

    # The modern default config file name is bridgetown.config.EXT, but we also
    # need to check for _config.EXT as a backward-compatibility nod to our
    # progenitor
    CONFIG_FILE_PREFIXES = %w(bridgetown.config _config).freeze
    CONFIG_FILE_EXTS = %w(yml yaml toml).freeze

    class << self
      # Static: Produce a Configuration ready for use in a Site.
      # It takes the input, fills in the defaults where values do not exist.
      #
      # user_config - a Hash or Configuration of overrides.
      #
      # Returns a Configuration filled with defaults.
      def from(user_config, starting_defaults = DEFAULTS)
        Utils.deep_merge_hashes(starting_defaults.deep_dup, Configuration[user_config])
          .merge_environment_specific_options!
          .add_default_collections
          .add_default_excludes
          .check_include_exclude
      end
    end

    def get_config_value_with_override(config_key, override)
      override[config_key] || self[config_key] || DEFAULTS[config_key]
    end

    # Public: Directory of the top-level root where config files are located
    #
    # override - the command-line options hash
    #
    # Returns the path to the Bridgetown root directory
    def root_dir(override)
      get_config_value_with_override("root_dir", override)
    end

    # Public: Directory of the Bridgetown source folder
    #
    # override - the command-line options hash
    #
    # Returns the path to the Bridgetown source directory
    def source(override)
      get_config_value_with_override("source", override)
    end

    def quiet(override = {})
      get_config_value_with_override("quiet", override)
    end
    alias_method :quiet?, :quiet

    def verbose(override = {})
      get_config_value_with_override("verbose", override)
    end
    alias_method :verbose?, :verbose

    def safe_load_file(filename)
      case File.extname(filename)
      when %r!\.toml!i
        Bridgetown::Utils::RequireGems.require_with_graceful_fail("tomlrb") unless defined?(Tomlrb)
        Tomlrb.load_file(filename)
      when %r!\.ya?ml!i
        YAMLParser.load_file(filename) || {}
      else
        raise ArgumentError,
              "No parser for '#{filename}' is available. Use a .y(a)ml or .toml file instead."
      end
    end

    # Public: Generate list of configuration files from the override
    #
    # override - the command-line options hash
    #
    # Returns an Array of config files
    def config_files(override)
      # Adjust verbosity quickly
      Bridgetown.logger.adjust_verbosity(
        quiet: quiet?(override),
        verbose: verbose?(override)
      )

      # Get configuration from <root_dir>/<matching_default_config>
      # or <root_dir>/<config_file> if there's a command line override.
      # By default only the first matching config file will be loaded, but
      # multiple configs can be specified via command line.
      config_files = override["config"]
      if config_files.to_s.empty?
        file_lookups = CONFIG_FILE_PREFIXES.map do |prefix|
          CONFIG_FILE_EXTS.map do |ext|
            Bridgetown.sanitized_path(root_dir(override), "#{prefix}.#{ext}")
          end
        end.flatten.freeze

        found_file = file_lookups.find do |path|
          File.exist?(path)
        end

        config_files = found_file || file_lookups.first
        @default_config_file = true
      end
      Array(config_files)
    end

    # Public: Read in a list of configuration files and merge with this hash
    #
    # files - the list of configuration file paths
    #
    # Returns the full configuration, with the defaults overridden by the values in the
    # configuration files
    def read_config_files(files)
      config = self

      begin
        files.each do |config_file|
          next if config_file.nil? || config_file.empty?

          new_config = read_config_file(config_file)
          config = Utils.deep_merge_hashes(self, new_config)
        end
      rescue ArgumentError => e
        Bridgetown.logger.warn "WARNING:", "Error reading configuration. Using defaults" \
                                " (and options)."
        warn e
      end

      config
    end

    # Public: Read configuration and return merged Hash
    #
    # file - the path to the YAML file to be read in
    #
    # Returns this configuration, overridden by the values in the file
    def read_config_file(file)
      file = File.expand_path(file)
      next_config = safe_load_file(file)

      unless next_config.is_a?(Hash)
        raise ArgumentError, "Configuration file: (INVALID) #{file}".yellow
      end

      Bridgetown.logger.info "Configuration file:", file
      next_config
    rescue SystemCallError
      if @default_config_file ||= nil
        Bridgetown.logger.warn "Configuration file:", "none"
        {}
      else
        Bridgetown.logger.error "Fatal:", "The configuration file '#{file}' could not be found."
        raise LoadError, "The Configuration file '#{file}' could not be found."
      end
    end

    # Merge in environment-specific options, if present
    def merge_environment_specific_options!
      self[Bridgetown.environment]&.each_key do |k|
        self[k] = self[Bridgetown.environment][k]
      end
      delete(Bridgetown.environment)
      self
    end

    def add_default_collections # rubocop:todo all
      # It defaults to `{}`, so this is only if someone sets it to null manually.
      return self if self[:collections].nil?

      # Ensure we have a hash.
      if self[:collections].is_a?(Array)
        self[:collections] = self[:collections].each_with_object({}) do |collection, hash|
          hash[collection] = {}
        end
      end

      # Setup default collections
      self[:collections][:posts] = {} unless self[:collections][:posts]
      self[:collections][:posts][:output] = true
      self[:collections][:posts][:sort_direction] ||= "descending"

      if self[:content_engine] == "resource"
        self[:permalink] = "pretty" if self[:permalink].blank?
        self[:collections][:pages] = {} unless self[:collections][:pages]
        self[:collections][:pages][:output] = true
        self[:collections][:pages][:permalink] ||= "/:path/"

        self[:collections][:data] = {} unless self[:collections][:data]
        self[:collections][:data][:output] = false

        unless self[:collections][:posts][:permalink]
          self[:collections][:posts][:permalink] = self[:permalink]
        end
      else
        self[:permalink] = "date" if self[:permalink].blank?
        unless self[:collections][:posts][:permalink]
          self[:collections][:posts][:permalink] = style_to_permalink(self[:permalink])
        end
      end

      self
    end

    DEFAULT_EXCLUDES = %w(
      .sass-cache .bridgetown-cache
      gemfiles Gemfile Gemfile.lock
      node_modules
      vendor/bundle/ vendor/cache/ vendor/gems/ vendor/ruby/
    ).freeze

    def add_default_excludes
      return self if self["exclude"].nil?

      self["exclude"].concat(DEFAULT_EXCLUDES).uniq!
      self
    end

    def should_execute_inline_ruby?
      ENV["BRIDGETOWN_RUBY_IN_FRONT_MATTER"] != "false" &&
        self["ruby_in_front_matter"]
    end

    # Deprecated, to be removed when Bridgetown goes Resource-only
    def style_to_permalink(permalink_style) # rubocop:todo Metrics/CyclomaticComplexity
      case permalink_style.to_s.to_sym
      when :pretty
        "/:categories/:year/:month/:day/:title/"
      when :simple
        "/:categories/:title/"
      when :none
        "/:categories/:title:output_ext"
      when :date
        "/:categories/:year/:month/:day/:title:output_ext"
      when :ordinal
        "/:categories/:year/:y_day/:title:output_ext"
      when :weekdate
        "/:categories/:year/W:week/:short_day/:title:output_ext"
      else
        permalink_style.to_s
      end
    end

    def check_include_exclude
      %w(include exclude).each do |option|
        next unless key?(option)
        next if self[option].is_a?(Array)

        raise Bridgetown::Errors::InvalidConfigurationError,
              "'#{option}' should be set as an array, but was: #{self[option].inspect}."
      end

      unless self[:include].include?("_pages") || self[:content_engine] == "resource"
        # add _pages to includes set
        self[:include] << "_pages"
      end

      self
    end
  end
end
