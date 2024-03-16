# frozen_string_literal: true

module Bridgetown
  class Configuration
    class ConfigurationDSL < Bridgetown::Utils::RubyFrontMatter
      attr_reader :context

      # @yieldself [ConfigurationDSL]
      def init(name, require_gem: true, require_initializer: true, **kwargs, &block) # rubocop:todo Metrics
        return if @scope.initializers.key?(name.to_sym) &&
          @scope.initializers[name.to_sym].completed

        initializer = _setup_initializer(
          name: name, require_gem: require_gem, require_initializer: require_initializer
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
        @scope.initializers[name.to_sym].block.(self, **@scope.init_params[name].symbolize_keys)
        initializer.completed = true
      end

      def only(*context, &block)
        return unless context.any? { _1 == @context }

        instance_exec(&block)
      end

      def except(*context, &block)
        return if context.any? { _1 == @context }

        instance_exec(&block)
      end

      def hook(
        owner,
        event,
        priority: Bridgetown::Hooks::DEFAULT_PRIORITY,
        &block
      )
        Bridgetown::Hooks.register_one(owner, event, priority: priority, reloadable: false, &block)
      end

      def source_manifest(**kwargs)
        @scope.source_manifests << SourceManifest.new(**kwargs)
      end

      def builder(klass = nil, &block)
        return klass.register if klass.is_a?(Class) && klass < Bridgetown::Builder

        unless klass.is_a?(Symbol)
          raise "You must supply a constant symbol to register an inline builder"
        end

        Object.const_set(
          klass, Class.new(Bridgetown::Builder, &block).tap(&:register)
        )
      end

      def roda(&block)
        @scope.roda_initializers << block
      end

      def timezone(tz) # rubocop:disable Naming/MethodParameterName
        Bridgetown.set_timezone(tz)
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

      def reflect(name, require_gem: true, require_initializer: true)
        initializer = _setup_initializer(
          name: name, require_gem: require_gem, require_initializer: require_initializer
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

          Bridgetown.logger.info("",
                                 "* #{param[1].to_s.cyan}#{" (required)" if param[0] == :keyreq}")
        end
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
    end
  end
end
