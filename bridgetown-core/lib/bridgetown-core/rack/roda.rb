# frozen_string_literal: true

module Bridgetown
  module Rack
    class Roda < ::Roda
      plugin :hooks
      plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
      plugin :json
      plugin :public, root: opts[:public_root]
      plugin :not_found do
        File.read("output/404.html")
      rescue Errno::ENOENT
        "404 Not Found"
      end
      plugin :error_handler do |e|
        puts "\n#{e.class} (#{e.message}):\n\n"
        puts e.backtrace
        File.read("output/500.html")
      rescue Errno::ENOENT
        "500 Internal Server Error"
      end

      def _roda_run_main_route(r)
        r.public

        r.root do
          File.read("output/index.html")
        end

        super
      end
    end
  end
end
