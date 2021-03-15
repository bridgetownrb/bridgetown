# frozen_string_literal: true

class Bridgetown::Site
  module Configurable
    # Set the site's configuration. This handles side-effects caused by
    #   changing values in the configuration.
    #
    # @param config [Configuration]
    #   An instance of {Configuration},
    #   containing the new configuration.
    #
    # @return [Configuration]
    #   The processed instance of {Configuration}
    def config=(config)
      @config = config.clone

      # Source and destination may not be changed after the site has been created.
      @root_dir        = File.expand_path(config["root_dir"]).freeze
      @source          = File.expand_path(config["source"]).freeze
      @dest            = File.expand_path(config["destination"]).freeze
      @cache_dir       = in_root_dir(config["cache_dir"]).freeze

      %w(lsi highlighter baseurl exclude include future unpublished
         limit_posts keep_files).each do |opt|
        send("#{opt}=", config[opt])
      end

      configure_cache
      configure_component_paths
      configure_include_paths
      configure_file_read_opts

      self.permalink_style = (config["permalink"] || "pretty").to_sym

      @config
    end

    def uses_resource?
      config[:content_engine] == "resource"
    end

    def defaults_reader
      @defaults_reader ||= Bridgetown::DefaultsReader.new(self)
    end

    # Returns the current instance of {FrontmatterDefaults} or
    #   creates a new instance {FrontmatterDefaults} if it doesn't already exist.
    #
    # @return [FrontmatterDefaults]
    #   Returns an instance of {FrontmatterDefaults}
    def frontmatter_defaults
      @frontmatter_defaults ||= Bridgetown::FrontmatterDefaults.new(self)
    end

    # Whether to perform a full rebuild without incremental regeneration.
    #   If either `override["incremental"]` or `config["incremental"]` are true,
    #   fully rebuild the site. If not, incrementally build the site.
    #
    # @param [Hash] override
    #   An override hash to override the current config value
    # @option override [Boolean] "incremental" Whether to incrementally build
    # @return [Boolean] true for full rebuild, false for normal build
    def incremental?(override = {})
      override["incremental"] || config["incremental"]
    end

    # Returns the current instance of {Publisher} or creates a new instance of
    #   {Publisher} if one doesn't exist.
    #
    # @return [Publisher] Returns an instance of {Publisher}
    def publisher
      @publisher ||= Bridgetown::Publisher.new(self)
    end

    # Prefix a path or paths with the {#root_dir} directory.
    #
    # @see Bridgetown.sanitized_path
    # @param paths [Array<String>]
    #   An array of paths to prefix with the root_dir directory using the
    #   {Bridgetown.sanitized_path} method.
    #
    # @return [Array<String>] Return an array of updated paths if multiple paths given.
    def in_root_dir(*paths)
      paths.reduce(root_dir) do |base, path|
        Bridgetown.sanitized_path(base, path.to_s)
      end
    end

    # Prefix a path or paths with the {#source} directory.
    #
    # @see Bridgetown.sanitized_path
    # @param paths [Array<String>]
    #   An array of paths to prefix with the source directory using the
    #   {Bridgetown.sanitized_path} method.
    # @return [Array<String>] Return an array of updated paths if multiple paths given.
    def in_source_dir(*paths)
      paths.reduce(source) do |base, path|
        Bridgetown.sanitized_path(base, path.to_s)
      end
    end

    # Prefix a path or paths with the {#dest} directory.
    #
    # @see Bridgetown.sanitized_path
    # @param paths [Array<String>]
    #   An array of paths to prefix with the destination directory using the
    #   {Bridgetown.sanitized_path} method.
    #
    # @return [Array<String>] Return an array of updated paths if multiple paths given.
    def in_dest_dir(*paths)
      paths.reduce(dest) do |base, path|
        Bridgetown.sanitized_path(base, path)
      end
    end

    # Prefix a path or paths with the {#cache_dir} directory.
    #
    # @see Bridgetown.sanitized_path
    # @param paths [Array<String>]
    #   An array of paths to prefix with the {#cache_dir} directory using the
    #   {Bridgetown.sanitized_path} method.
    #
    # @return [Array<String>] Return an array of updated paths if multiple paths given.
    def in_cache_dir(*paths)
      paths.reduce(cache_dir) do |base, path|
        Bridgetown.sanitized_path(base, path)
      end
    end

    # The full path to the directory that houses all the registered collections
    #  for the current site.
    #
    #  If `@collections_path` is specified use its value.
    #
    #  If `@collections` is not specified and `config["collections_dir"]` is
    #  specified, prepend it with {#source} and assign it to
    #  {#collections_path}.
    #
    #  If `@collections` is not specified and `config["collections_dir"]` is not
    #  specified, assign {#source} to `@collections_path`
    #
    # @return [String] Returns the full path to the collections directory
    # @see #config
    # @see #source
    # @see #collections_path
    # @see #in_source_dir
    def collections_path
      dir_str = config["collections_dir"]
      @collections_path ||= dir_str.empty? ? source : in_source_dir(dir_str)
    end

    private

    # Disable Marshaling cache to disk in Safe Mode
    def configure_cache
      Bridgetown::Cache.cache_dir = in_root_dir(config["cache_dir"], "Bridgetown/Cache")
      Bridgetown::Cache.disable_disk_cache! if config["disable_disk_cache"]
    end

    def configure_component_paths
      # Loop through plugins paths first
      plugin_components_load_paths = Bridgetown::PluginManager.source_manifests
        .map(&:components).compact

      local_components_load_paths = config["components_dir"].yield_self do |dir|
        dir.is_a?(Array) ? dir : [dir]
      end
      local_components_load_paths.map! do |dir|
        if !!(dir =~ %r!^\.\.?\/!)
          # allow ./dir or ../../dir type options
          File.expand_path(dir.to_s, root_dir)
        else
          in_source_dir(dir.to_s)
        end
      end

      @components_load_paths = plugin_components_load_paths + local_components_load_paths
    end

    def configure_include_paths
      @includes_load_paths = Array(in_source_dir(config["includes_dir"].to_s))
    end

    def configure_file_read_opts
      self.file_read_opts = {}
      file_read_opts[:encoding] = config["encoding"] if config["encoding"]
      self.file_read_opts = Bridgetown::Utils.merged_file_read_opts(self, {})
    end
  end
end
