# frozen_string_literal: true

module Bridgetown
  module Routes
    module CodeBlocks
      class << self
        attr_accessor :blocks

        def add_route(name, file_code = nil, &block)
          block.instance_variable_set(:@_route_file_code, file_code) if file_code

          @blocks ||= {}
          @blocks[name] = block
        end

        # @param name [String]
        def route_defined?(name)
          blocks&.key?(name)
        end

        def route_block(name)
          blocks[name] if route_defined?(name)
        end
      end
    end
  end
end
