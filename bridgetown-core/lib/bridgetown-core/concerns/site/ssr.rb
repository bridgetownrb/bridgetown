# frozen_string_literal: true

class Bridgetown::Site
  module SSR
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Establish an SSR pipeline for a persistent backend process
      def start_ssr! # rubocop:todo Metrics/AbcSize
        if Bridgetown::Current.site
          raise Bridgetown::Errors::FatalException, "Bridgetown SSR already started! " \
                                                    "Check your Rack app for threading issues"
        end

        Bridgetown::PluginManager.require_from_bundler
        site = new(Bridgetown::Current.preloaded_configuration)
        site.enable_ssr

        Bridgetown::Hooks.trigger :site, :pre_read, site
        site.defaults_reader.tap do |d|
          d.path_defaults.clear
          d.read
        end
        site.layouts = Bridgetown::LayoutReader.new(site).read
        site.collections.data.tap do |coll|
          coll.read
          site.data = coll.merge_data_resources
        end
        Bridgetown::Hooks.trigger :site, :post_read, site

        yield(site) if block_given? # provide additional setup hook

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

    def disable_ssr
      Bridgetown.logger.info "SSR:", "now disabled."
      @ssr_enabled = false
    end
  end
end
