# frozen_string_literal: true

class Roda
  module RodaPlugins
    module BridgetownSSR
      module InstanceMethods
        # Helper to get the site associated with the Roda app
        # @return [Bridgetown::Site]
        def bridgetown_site
          self.class.opts[:bridgetown_site]
        end
      end

      def self.configure(app, _opts = {}, &block)
        app.include Bridgetown::Filters::URLFilters
        app.opts[:bridgetown_site] =
          Bridgetown::Site.start_ssr!(loaders_manager: Bridgetown::Rack.loaders_manager, &block)
      end
    end

    register_plugin :bridgetown_ssr, BridgetownSSR
  end
end
