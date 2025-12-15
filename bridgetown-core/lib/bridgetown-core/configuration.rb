# frozen_string_literal: true

module Bridgetown
  # The primary configuration object for a Bridgetown project
  class Configuration < HashWithDotAccess::Hash
    using Bridgetown::Refinements

    # Built-in initializer list which isn't Gem-backed:
    REQUIRE_DENYLIST = %i(external_sources parse_routes ssr) # rubocop:disable Style/MutableConstant

    Initializer = Struct.new(:name, :block, :completed) do
      def to_s
        "#{name} (Initializer)"
      end
    end

    SourceManifest = Struct.new(:origin, :components, :contents, :layouts, :bare_text) do
      def initialize(**kwargs)
        # for backwards compatibility, we need to support plugin code which sets `content`
        # directly, rather than uses the new multi-collections `contents` hash
        if kwargs[:content]
          kwargs[:contents] = { pages: kwargs[:content] }
          kwargs.delete :content
        end

        super
      end

      def content
        Bridgetown::Deprecator.deprecation_message(
          "source_manifest.content is deprecated, use " \
          "source_manifest.contents instead"
        )
        contents.values.first
      end
    end

    Preflight = Struct.new(:source_manifests, :initializers) do
      def initialize(*)
        super
        self.source_manifests ||= Set.new
      end
    end

    require_relative "configuration/configuration_dsl"

    # Default options. Overridden by values in bridgetown.config.yml or initializers.
    # Strings rather than symbols are used for compatibility with YAML.
    DEFAULTS = {
      # Where things are
      "root_dir"                     => Dir.pwd,
      "source"                       => "src",
      "destination"                  => "output",
      "plugins_dir"                  => "plugins",
      "server_dir"                   => "server",
      "collections_dir"              => "",
      "cache_dir"                    => ".bridgetown-cache",
      "layouts_dir"                  => "_layouts",
      "components_dir"               => "_components",
      "islands_dir"                  => "_islands",
      "partials_dir"                 => "_partials",
      "collections"                  => {},
      "taxonomies"                   => {
        category: { key: "categories", title: "Category" }, tag: { key: "tags", title: "Tag" },
      },
      "autoload_paths"               => [],
      "inflector"                    => Bridgetown::Foundation::Inflector.new,
      "eager_load_paths"             => [],
      "autoloader_collapsed_paths"   => [],
      "additional_watch_paths"       => [],
      "defaults"                     => [],

      # Handling Reading
      "include"                      => [".htaccess", "_redirects", ".well-known"],
      "exclude"                      => [],
      "keep_files"                   => [".git", ".svn", "_bridgetown"],
      "encoding"                     => "utf-8",
      "markdown_ext"                 => "markdown,mkdown,mkdn,mkd,md",
      "strict_front_matter"          => false,
      "slugify_mode"                 => "pretty",

      # Filtering Content
      "future"                       => false,
      "unpublished"                  => false,
      "ruby_in_front_matter"         => true,

      # Conversion
      "template_engine"              => "erb",
      "markdown"                     => "kramdown",
      "highlighter"                  => "rouge",
      "support_data_as_view_methods" => true,

      # Output Configuration
      "base_path"                    => "/",
      "available_locales"            => [:en],
      "default_locale"               => :en,
      "prefix_default_locale"        => false,
      "permalink"                    => "pretty",
      "timezone"                     => nil, # use the local timezone

      "quiet"                        => false,
      "verbose"                      => false,

      "liquid"                       => {
        "error_mode"       => "warn",
        "strict_filters"   => false,
        "strict_variables" => false,
      },

      "kramdown"                     => {
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
        "mark_highlighting"       => true,
      },

      "development"                  => {
        "fast_refresh" => true,
      },
    }.each_with_object(Configuration.new) { |(k, v), hsh| hsh[k] = v.freeze }.freeze

    # @return [Hash<Symbol, Initializer>]
    attr_accessor :initializers

    attr_writer :source_manifests, :roda_initializers

    class << self
      # Produce a Configuration ready for use in a Site.
      # It takes the input, fills in the defaults where values do not exist.
      #
      # @param user_config [Hash, Configuration]
      # @return [Configuration] filled with defaults
      def from(user_config, starting_defaults = DEFAULTS)
        Utils.deep_merge_hashes(starting_defaults.deep_dup, Configuration.new(user_config))
          .merge_environment_specific_options!
          .setup_load_paths!
          .setup_locales
          .add_default_collections
          .add_destination_paths
          .check_include_exclude
      end
    end

    def initializers_dsl(context:)
      ConfigurationDSL.new(scope: self, data: self).tap do |dsl|
        dsl.instance_variable_set(:@context, context)
      end
    end

    def run_initializers!(context:) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity
      initializers_file = File.join(root_dir, "config", "initializers.rb")
      unless File.file?(initializers_file)
        setup_load_paths! appending: true
        return
      end

      load initializers_file

      return unless initializers # no initializers have been set up

      init_init = initializers[:init]
      return unless init_init && !init_init.completed

      Bridgetown.logger.debug "Initializing:", "Running initializers with `#{context}' context in:"
      Bridgetown.logger.debug "", initializers_file
      self.init_params = {}
      cached_url = url&.include?("//localhost") ? url : nil
      dsl = initializers_dsl(context:)
      dsl.instance_exec(dsl, &init_init.block)
      dsl._run_builtins!
      self.url = cached_url if cached_url # restore local development URL if need be

      setup_post_init!

      self
    end

    def setup_post_init!
      add_destination_paths.setup_load_paths! appending: true
    end

    # @return [Set<SourceManifest>]
    def source_manifests
      @source_manifests ||= Set.new
    end

    # @return [Array<Proc>]
    def roda_initializers
      @roda_initializers ||= []
    end

    def initialize_roda_app(app)
      roda_initializers.each do |initializer|
        initializer.(app)
      end
    end

    def get_config_value_with_override(config_key, override)
      override[config_key] || self[config_key] || DEFAULTS[config_key]
    end

    # Directory of the top-level root where config files are located
    #
    # @param override [Hash] options hash which will override value if key is present
    # @return [String] path to the Bridgetown root directory
    def root_dir(override = {})
      get_config_value_with_override("root_dir", override)
    end

    # Directory of the Bridgetown source folder
    #
    # @param override [Hash] options hash which will override value if key is present
    # @return [String]  path to the Bridgetown source directory
    def source(override = {})
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
      YAMLParser.load_file(filename) || {}
    rescue Psych::DisallowedClass => e
      raise "Unable to parse `#{File.basename(filename)}'. #{e.message}"
    end

    # Generate list of configuration files from the override
    #
    # @param override [Hash] the command-line options hash
    # @return [Array<string>] config files
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
      config_files = "bridgetown.config.yml" if config_files.to_s.empty?
      Array(config_files)
    end

    # Read in a list of configuration files and merge with this hash
    #
    # @param files [Array<String>]
    # @return [Hash] configuration with the defaults overridden by the values in the
    #   configuration files
    def read_config_files(files)
      config = self

      begin
        files.each do |config_file|
          next if config_file.nil? || config_file.empty?

          new_config = read_config_file(config_file)
          config = Utils.deep_merge_hashes(self, new_config)
        end
      rescue ArgumentError => e
        Bridgetown.logger.warn "WARNING:", "Error reading configuration. Using defaults " \
                                           "(and options)."
        warn e
      end

      config
    end

    # Read configuration and return merged Hash
    #
    # @param file [String] the path to the YAML file to be read in
    # @return [Hash]
    def read_config_file(file)
      default_config_file = file == "bridgetown.config.yml"
      file = File.expand_path(file)
      # We don't care if default config is missing, we can return blank:
      return {} if !File.exist?(file) && default_config_file

      file_config = safe_load_file(file)

      unless file_config.is_a?(Hash)
        raise ArgumentError, "Configuration file: (INVALID) #{file}".yellow
      end

      Bridgetown.logger.debug "Configuration file:", file
      file_config
    rescue SystemCallError
      Bridgetown.logger.error "Fatal:", "The configuration file '#{file}' could not be found."
      raise LoadError, "missing configuration file"
    end

    # Merge in environment-specific options, if present
    def merge_environment_specific_options!
      self[Bridgetown.environment]&.each_key do |k|
        self[k] = self[Bridgetown.environment][k]
      end
      delete(Bridgetown.environment)

      self
    end

    def setup_load_paths!(appending: false) # rubocop:todo Metrics
      self[:root_dir] = File.expand_path(self[:root_dir])
      self[:source] = File.expand_path(self[:source], self[:root_dir])
      self[:destination] = File.expand_path(self[:destination], self[:root_dir])

      unless appending
        autoload_paths.unshift({
          path: File.expand_path(self[:plugins_dir], self[:root_dir]),
          eager: true,
        })
        autoload_paths.unshift({
          path: File.expand_path(self[:islands_dir], self[:source]),
          eager: true,
        })
      end

      autoload_paths.map! do |load_path|
        if load_path.is_a?(Hash)
          expanded = File.expand_path(load_path[:path], self[:root_dir])
          self[:eager_load_paths] << expanded if load_path[:eager]
          next expanded
        end

        File.expand_path(load_path, self[:root_dir])
      end

      autoloader_collapsed_paths.map! do |collapsed_path|
        File.expand_path(collapsed_path, self[:root_dir])
      end

      additional_watch_paths.map! do |collapsed_path|
        File.expand_path(collapsed_path, self[:root_dir])
      end

      self
    end

    def setup_locales
      self.default_locale = default_locale.to_sym
      available_locales.map!(&:to_sym)
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

      self[:collections][:pages] = {} unless self[:collections][:pages]
      self[:collections][:pages][:output] = true

      self[:collections][:data] = {} unless self[:collections][:data]
      self[:collections][:data][:output] = false

      self
    end

    DEFAULT_EXCLUDES = %w(
      .sass-cache/ .bridgetown-cache/ tmp/
      gemfiles Gemfile Gemfile.lock gems.rb gems.locked
      node_modules/ config/
      vendor/bundle/ vendor/cache/ vendor/gems/ vendor/ruby/
    ).freeze

    def add_destination_paths
      self["keep_files"] << "_bridgetown" unless
        self["keep_files"].nil?.! && self["keep_files"].include?("_bridgetown")

      return self if self["exclude"].nil?

      self["exclude"].concat(DEFAULT_EXCLUDES).uniq!
      self
    end

    alias_method :add_default_excludes, :add_destination_paths

    def should_execute_inline_ruby?
      ENV["BRIDGETOWN_RUBY_IN_FRONT_MATTER"] != "false" &&
        self["ruby_in_front_matter"]
    end

    def check_include_exclude
      %w(include exclude).each do |option|
        next unless key?(option)
        next if self[option].is_a?(Array)

        raise Bridgetown::Errors::InvalidConfigurationError,
              "'#{option}' should be set as an array, but was: #{self[option].inspect}."
      end

      self
    end

    # Whether or not PostCSS is being used to process stylesheets.
    #
    # @return [Boolean] true if `postcss.config.js` exists, false if not
    def uses_postcss?
      File.exist?(Bridgetown.sanitized_path(root_dir, "postcss.config.js"))
    end
  end
end
