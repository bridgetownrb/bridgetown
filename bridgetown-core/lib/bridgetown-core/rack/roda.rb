# frozen_string_literal: true

require "rack/indifferent"

class Roda
  module RodaPlugins
    module BridgetownSSR
      def self.configure(app, _opts = {}, &block)
        app.opts[:bridgetown_site] =
          Bridgetown::Site.start_ssr!(loaders_manager: Bridgetown::Rack.loaders_manager, &block)
      end
    end

    register_plugin :bridgetown_ssr, BridgetownSSR
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

      def _roda_run_main_route(r) # rubocop:disable Naming/MethodParameterName
        if self.class.opts[:bridgetown_site]
          # The site had previously been initialized via the bridgetown_ssr plugin
          Bridgetown::Current.site ||= self.class.opts[:bridgetown_site]
        end
        Bridgetown::Current.preloaded_configuration ||=
          self.class.opts[:bridgetown_preloaded_config]

        r.public

        r.root do
          output_folder = Bridgetown::Current.preloaded_configuration.destination
          File.read(File.join(output_folder, "index.html"))
        end

        super
      end

      # Helper shorthand for Bridgetown::Current.site
      # @return [Bridgetown::Site]
      def bridgetown_site
        Bridgetown::Current.site
      end
    end
  end
end
