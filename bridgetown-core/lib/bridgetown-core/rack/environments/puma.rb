# frozen_string_literal: true

module Bridgetown
  module Rack
    module Environment
      module Puma
        def port
          @port || ENV["BRIDGETOWN_PORT"] || "4000"
        end

        def bind
          @bind || "tcp://0.0.0.0"
        end

        def rack_config
          "config.ru"
        end

        def options
          []
        end

        def command
          ["puma", "-b", bind, "-p", port.to_s, *options, rack_config]
        end
      end
    end
  end
end
