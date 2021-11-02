# frozen_string_literal: true

class Bridgetown::Site
  module SSR
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Establish an SSR pipeline for a persistent backend process
      def start_ssr!(loaders_manager: nil, &block)
        if Bridgetown::Current.site
          raise Bridgetown::Errors::FatalException, "Bridgetown SSR already started! " \
                                                    "Check your Rack app for threading issues"
        end

        Bridgetown::PluginManager.require_from_bundler
        site = new(Bridgetown::Current.preloaded_configuration, loaders_manager: loaders_manager)
        site.enable_ssr
        site.ssr_setup(&block)

        site
      end
    end

    def ssr?
      @ssr_enabled == true
    end

    def enable_ssr
      Bridgetown.logger.info "SSR:", "enabled."
      @ssr_enabled = true
    end

    def ssr_setup(&block) # rubocop:disable Metrics/AbcSize
      config.serving = true
      Bridgetown::Hooks.trigger :site, :pre_read, self
      defaults_reader.tap do |d|
        d.path_defaults.clear
        d.read
      end
      reader.read_layouts
      collections.data.tap do |coll|
        coll.read
        self.data = coll.merge_data_resources
      end
      Bridgetown::Hooks.trigger :site, :post_read, self

      hook = block&.(self) # provide additional setup hook
      return if Bridgetown.env.production?

      @ssr_reload_hook = hook if hook.is_a?(Proc) && hook.lambda?
      Bridgetown::Watcher.watch(self, config)
    end

    def ssr_reload
      reset soft: true
      reader.read_layouts

      collections.data.tap do |coll|
        coll.resources.clear
        coll.read
        coll.merge_data_resources.each do |k, v|
          data[k] = v
        end
      end
      @ssr_reload_hook.() if @ssr_reload_hook.is_a?(Proc)
    end

    def disable_ssr
      Bridgetown.logger.info "SSR:", "now disabled."
      @ssr_enabled = false
    end
  end
end
