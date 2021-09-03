# frozen_string_literal: true

module Bridgetown
  module Rack
    class Roda < ::Roda
      plugin :hooks
      plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
      plugin :json
      plugin :json_parser
      plugin :cookies
      plugin :public, root: opts[:public_root]
      plugin :not_found do
        output_folder = Bridgetown::Current.preloaded_configuration&.destination || "output"
        File.read(File.join(output_folder, "404.html"))
      rescue Errno::ENOENT
        "404 Not Found"
      end
      plugin :error_handler do |e|
        puts "\n#{e.class} (#{e.message}):\n\n"
        puts e.backtrace
        output_folder = Bridgetown::Current.preloaded_configuration&.destination || "output"
        File.read(File.join(output_folder, "500.html"))
      rescue Errno::ENOENT
        "500 Internal Server Error"
      end

      def _roda_run_main_route(r) # rubocop:disable Naming/MethodParameterName
        Bridgetown::Current.preloaded_configuration = Roda.opts[:bridgetown_preloaded_config]

        r.public

        r.root do
          output_folder = Bridgetown::Current.preloaded_configuration&.destination || "output"
          File.read(File.join(output_folder, "index.html"))
        end

        super
      end
    end
  end
end
