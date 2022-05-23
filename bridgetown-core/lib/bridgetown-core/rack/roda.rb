# frozen_string_literal: true

require "rack/indifferent"

begin
  # If it's in the Gemfile's :bridgetown_plugins group it's already been required, but we'll try
  # again just to be on the safe side:
  require "bridgetown-routes"
rescue LoadError
end

class Roda
  module RodaPlugins
    module BridgetownSSR
      def self.configure(app, _opts = {}, &block)
        app.opts[:bridgetown_site] =
          Bridgetown::Site.start_ssr!(loaders_manager: Bridgetown::Rack.loaders_manager, &block)
      end
    end

    register_plugin :bridgetown_ssr, BridgetownSSR

    module BridgetownBoot
      module InstanceMethods
        # Helper shorthand for Bridgetown::Current.site
        # @return [Bridgetown::Site]
        def bridgetown_site
          Bridgetown::Current.site
        end
      end

      Roda::RodaRequest.alias_method :_previous_roda_cookies, :cookies

      module RequestMethods
        # Monkeypatch Roda/Rack's Request object so it returns a hash which allows for
        # indifferent access
        def cookies
          # TODO: maybe replace with a simpler hash that offers an overloaded `[]` method
          _previous_roda_cookies.with_indifferent_access
        end

        # Starts up the Bridgetown routing system
        def bridgetown
          Bridgetown::Rack::Routes.start!(scope)
        end
      end
    end

    register_plugin :bridgetown_boot, BridgetownBoot
  end
end

module Bridgetown
  module Rack
    class Roda < ::Roda
      plugin :hooks
      plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
      plugin :json
      plugin :json_parser
      plugin :cookies
      plugin :streaming
      plugin :bridgetown_boot
      plugin :public, root: Bridgetown::Current.preloaded_configuration.destination
      plugin :not_found do
        output_folder = Bridgetown::Current.preloaded_configuration.destination
        File.read(File.join(output_folder, "404.html"))
      rescue Errno::ENOENT
        "404 Not Found"
      end
      plugin :error_handler do |e|
        puts "\n#{e.class} (#{e.message}):\n\n"
        puts e.backtrace
        output_folder = Bridgetown::Current.preloaded_configuration.destination
        File.read(File.join(output_folder, "500.html"))
      rescue Errno::ENOENT
        "500 Internal Server Error"
      end

      before do
        if self.class.opts[:bridgetown_site]
          # The site had previously been initialized via the bridgetown_ssr plugin
          Bridgetown::Current.site ||= self.class.opts[:bridgetown_site]
        end
        Bridgetown::Current.preloaded_configuration ||=
          self.class.opts[:bridgetown_preloaded_config]

        request.root do
          output_folder = Bridgetown::Current.preloaded_configuration.destination
          File.read(File.join(output_folder, "index.html"))
        rescue StandardError
          response.status = 500
          "<p>ERROR: cannot find <code>index.html</code> in the output folder.</p>"
        end
      end
    end
  end
end
