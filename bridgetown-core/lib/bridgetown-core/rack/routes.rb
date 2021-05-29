# frozen_string_literal: true

module Bridgetown
  module Rack
    class Routes
      class << self
        attr_accessor :router_block
      end
      def self.route(&block)
        self.router_block = block
      end

      def self.merge(app)
        return unless router_block

        app.instance_exec(app.request, &router_block)
      end
    end
  end
end
