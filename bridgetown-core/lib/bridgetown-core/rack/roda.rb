# frozen_string_literal: true

module Bridgetown
  module Rack
    class Roda < ::Roda
      plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
      plugin :json
      plugin :public, root: opts[:public_root]
      plugin :not_found do
        File.read("output/404.html")
      end

      def bridgetown_setup(r)
        r.public

        r.root do
          File.read("output/index.html")
        end
      end
    end
  end
end
