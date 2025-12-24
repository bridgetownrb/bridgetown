# frozen_string_literal: true

module Bridgetown
  class Configuration
    class ConfigurationDSL < Bridgetown::FrontMatter::RubyFrontMatter
      include Bridgetown::Refinements::Helper

      attr_reader :context

      # Initialize a Bridgetown plugin, optionally passing along configuration data. By default,
      # requires the associated Ruby gem as well, but this can be switched off for local
      # initializer files.
      #
      # @param name [Symbol]
      # @param require_gem [Boolean] set `false` if you don't want the named gem to be required
      # @param require_initializer [Boolean] set `false` if the named file in your `config` folder
      #   shouldn't get processed as an initializer
      # @param kwargs [Hash] pass keyword arguments as configuration along to the plugin. This can
      #   also be accomplished via a block using "Ruby front matter" syntax
      # @yieldreceiver [ConfigurationDSL]
      # @return [void]
      def init(name, require_gem: true, require_initializer: true, **kwargs, &block) # rubocop:todo Metrics
        return if @scope.initializers.key?(name.to_sym) &&
          @scope.initializers[name.to_sym].completed

        initializer = _setup_initializer(
          name:, require_gem:, require_initializer:
        )

        return unless initializer.nil? || initializer.completed == false

        set :init_params do
          block ? set(name, &block) : set(name, kwargs)
        end

        if initializer.nil?
          Bridgetown.logger.warn("Initializing:",
                                 "The `#{name}' initializer could not be found")
          return
        end

        Bridgetown.logger.debug "Initializing:", name
        @scope.initializers[name.to_sym].block.(
          self, **@scope.init_params[name].transform_keys(&:to_sym)
        )
        initializer.completed = true
      end

      # Execute the provided block for configuration only if the current context matches the
      # provided criteria.
      #
      # @param context [Symbol] supply one or more contexts for execution. Generally these are
      #   `:static`, `:console`, `:rake`, and `:server`
      # @return [void]
      def only(*context, &)
        return unless context.any? { _1 == @context }

        instance_exec(&)
      end

      # Do not execute the provided block for configuration if the current context matches the
      # provided criteria.
      #
      # @param context [Symbol] supply one or more contexts for avoiding execution. Generally these
      #   are `:static`, `:console`, `:rake`, and `:server`
      # @return [void]
      def except(*context, &)
        return if context.any? { _1 == @context }

        instance_exec(&)
      end

      # Provides a wrapper around the `register_one` method of the `Hooks` class.
      #
      # @see Bridgetown::Hooks.register_one
      # @param owner [Symbol] name of the owner (`:site`, `:resource`, etc.)
      # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
      # @param priority [Integer, Symbol] either `:low`, `:normal`, or `:high`, or an integer.
      #   Default is normal (20)
      # @yield the block will be called when the event is triggered. Typically it receives at
      #   least one argument.
      # @yieldparam obj the object which triggered the event hook
      def hook(
        owner,
        event,
        priority: Bridgetown::Hooks::DEFAULT_PRIORITY,
        &
      )
        Bridgetown::Hooks.register_one(owner, event, priority:, reloadable: false, &)
      end

      # Used by plugins to supply a source manifest.
      #
      # @see SourceManifest.new
      # @return [void]
      def source_manifest(**)
        @scope.source_manifests << SourceManifest.new(**)
      end

      # Used by plugins to register the provided Builder class, or alternatively
      # register an "inline builder" by defining the class body in a block using the
      # provided symbol as the class name.
      #
      # @param klass [Class<Bridgetown::Builder>, Symbol]
      # @return [void]
      def builder(klass = nil, &)
        return klass.register if klass.is_a?(Class) && klass < Bridgetown::Builder

        unless klass.is_a?(Symbol)
          raise "You must supply a constant symbol to register an inline builder"
        end

        Object.const_set(
          klass, Class.new(Bridgetown::Builder, &).tap(&:register)
        )
      end

      # Define an initializer block which is called when the Roda server is being configured.
      #
      # @yieldparam app [Class<Roda>]
      # @return [void]
      def roda(&block)
        @scope.roda_initializers << block
      end

      # Set the TZ environment variable to use the timezone specified
      #
      # @param timezone [String] the IANA Time Zone
      # @return [void]
      def timezone(new_timezone)
        @data[:timezone] = new_timezone
        Bridgetown.set_timezone(new_timezone)
      end

      def method_missing(key, *value, &block) # rubocop:disable Style/MissingRespondToMissing
        return get(key) if value.empty? && block.nil?

        set(key, value[0], &block)
      end

      def get(key)
        unless @data.key?(key)
          Bridgetown.logger.debug("Initializing:", "Uh oh, missing key `#{key}' in configuration")
        end

        super
      end

      def set(key, value = nil, &block)
        # Handle nested data within a block
        if block
          value = self.class.new(scope: @scope).tap do |fm|
            fm.instance_exec(&block)
          end.to_h
        end

        key = key.to_s.delete_suffix("=") if key.to_s.ends_with?("=")

        @data[key] = if @data[key].is_a?(Hash) && value.is_a?(Hash)
                       Bridgetown::Utils.deep_merge_hashes(@data[key], value)
                     else
                       value
                     end
      end

      # Similar to `init` but it simply prints out a list of the configuration options accepted
      # as keyword arguments by the initializer
      def reflect(name, require_gem: true, require_initializer: true)
        initializer = _setup_initializer(
          name:, require_gem:, require_initializer:
        )

        if initializer.nil?
          Bridgetown.logger.info("Reflection:",
                                 "The `#{name}' initializer could not be found")
          return
        end

        Bridgetown.logger.info(
          "Reflection:",
          "The #{name.to_s.yellow} initializer accepts the following options:"
        )
        initializer.block.parameters.each do |param|
          next if param[0] == :opt

          option = param[1].to_s
          option = "** #{option}" if param[0] == :keyrest

          Bridgetown.logger.info("",
                                 "- #{option.cyan}#{" (required)" if param[0] == :keyreq}")
        end

        nil
      end

      # @return [Bridgetown::Configuration::Initializer]
      def _setup_initializer(name:, require_gem:, require_initializer:)
        Bridgetown::PluginManager.require_gem(name) if require_gem && !_in_require_denylist?(name)

        if require_initializer
          init_file_name = File.join(@scope.root_dir, "config", "#{name}.rb")
          load(init_file_name) if File.exist?(init_file_name)
        end

        @scope.initializers[name.to_sym]
      end

      def _in_require_denylist?(name)
        REQUIRE_DENYLIST.include?(name.to_sym)
      end

      # Initializers that are part of the Bridgetown boot sequence. Site owners can override
      # defaults by running any of these manually…init is no-op if the initializer was already run.
      def _run_builtins!
        init :streamlined
      end

      ### Document configuration options ###
      # TODO: many more to follow!

      # @!method url(url)
      #   Sets the base URL for absolute links. (This will be overridden with something like
      #   `localhost:4000` in development.)
      #   @param url [String]

      # @!method source(path)
      #   Change the directory where Bridgetown will read content files
      #   @param path [String] - default: `src`

      # @!method destination(path)
      #   Change the directory where Bridgetown will write files
      #   @param path [String] - default: `output`

      # @!method template_engine(engine)
      #   Change the template engine Bridgetown uses by default to process content files
      #   @param engine [Symbol] - default: `:erb`, alternatives: `:serbea`, `:liquid`

      # @!method permalink(style)
      #   Change the default permalink style or template used by pages & blog posts
      #   @param style [String] - default: `:pretty`, alternatives: `:pretty_ext`, `:simple`, `:simple_ext`

      # @!method fast_refresh(bool)
      #   Control the behavior of Bridgetown's live reload functionality in development
      #   @param bool [Boolean] - default: `true`

      # @!method exclude(files_list)
      #   Exclude source directories and/or files from the build conversion
      #   @param files_list [Array<String>]

      # @!method include(files_list)
      #   Force inclusion of directories and/or files in the conversion (e.g. starting with underscores or dots)
      #   @param files_list [Array<String>]

      # @!method keep_files(files_list)
      #   Files to keep when clobbering the site destination (aka not generated in typical Bridgetown builds)
      #   @param files_list [Array<String>]

      # @!method autoload_paths
      #   Add paths to the Zeitwerk autoloader. Use a `config.defaults << "..."` syntax or a more advanced hash config
      #   @example Add a new path for autoloading and eager load on boot
      #       config.autoload_paths << {
      #         path: "loadme",
      #         eager: true
      #       }

      # @!method additional_watch_paths(paths)
      #   Watch additional directories for reloads not normally covered by autoloader (relative to project root)
      #   @param paths [Array<String>]

      # @!method timezone(zone)
      #   Set the time zone for site generation, using IANA Time Zone Database
      #   @param zone [String]

      # @!method defaults
      #   Use a `config.defaults << {...}` syntax to add front matter defaults
      #   @example Set a default layout for a collection
      #       config.defaults << {
      #         scope: { collection: :docs },
      #         values: { layout: :default },
      #       }

      # @!method pagination
      #   Enable and configure the settings for the paginator
      #   @example Basic setup
      #       pagination do
      #         enabled true
      #       end

      # @!method base_path(url)
      #   Optionally host your site off a path, e.g. `/blog`
      #   @param url [String] - default: `/`

      # @!method inflector
      #   Configure the inflector to add new inflection types, based on `Dry::Inflector`
      #   @return [Bridgetown::Foundation::Inflector]
    end
  end
end
