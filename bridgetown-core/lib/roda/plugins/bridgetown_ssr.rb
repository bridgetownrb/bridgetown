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

        alias_method :site, :bridgetown_site
      end

      def self.load_dependencies(app, opts = { sessions: false })
        app.plugin :all_verbs
        app.plugin :cookies, path: "/"
        app.plugin :indifferent_params
        app.plugin :method_override
        app.plugin :route_csrf

        # This lets us return callable objects directly in Roda response blocks
        app.plugin :custom_block_results
        app.handle_block_result(Bridgetown::RodaCallable) do |callable|
          callable.(self)
        end

        return unless opts[:sessions]

        secret_key = ENV.fetch("RODA_SECRET_KEY", nil)
        unless secret_key
          raise Bridgetown::Errors::InvalidConfigurationError,
                "The Roda sessions plugin can't find a valid secret. Run " \
                "`bin/bridgetown secret' and put the key in your ENV as the " \
                "RODA_SECRET_KEY variable"
        end

        app.plugin :sessions, secret: secret_key
        app.plugin :flashier
      end

      def self.configure(app, _opts = {}, &)
        app.include Bridgetown::Filters::URLFilters
        app.opts[:bridgetown_site] =
          Bridgetown::Site.start_ssr!(loaders_manager: Bridgetown::Rack.loaders_manager, &)
      end
    end

    register_plugin :bridgetown_ssr, BridgetownSSR
  end
end
