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

    def ssr_setup(&block)
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

      block&.call(self) # provide additional setup hook
      return if Bridgetown.env.production?

      Bridgetown::Watcher.watch(self, config, &block)
    end

    def disable_ssr
      Bridgetown.logger.info "SSR:", "now disabled."
      @ssr_enabled = false
    end
  end
end
