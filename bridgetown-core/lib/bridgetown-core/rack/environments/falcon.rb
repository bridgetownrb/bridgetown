# frozen_string_literal: true

module Bridgetown
  module Rack
    module Environment
      module Falcon
        def port
          @port || ENV["BRIDGETOWN_PORT"] || "4000"
        end

        def scheme
          :https
        end

        def bind
          @bind || "#{scheme}://localhost"
        end

        def rack_config
          "config.ru"
        end

        def workers
          1
        end

        def options
          []
        end

        def command
          ["falcon", "serve",
           "--bind", bind,
           "--port", port.to_s,
           "--config", rack_config,
           "--count", workers.to_s,
           *options,]
        end
      end
    end
  end
end
