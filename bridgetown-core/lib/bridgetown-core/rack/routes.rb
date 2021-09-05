# frozen_string_literal: true

module Bridgetown
  module Rack
    class Routes
      extend ActiveSupport::DescendantsTracker

      class << self
        attr_accessor :router_block
      end
      def self.route(&block)
        self.router_block = block
      end

      def self.merge(roda_app)
        return unless router_block

        new(roda_app).handle_routes
      end

      def self.start!(roda_app)
        descendants.each do |klass|
          klass.merge roda_app
        end
      end

      def initialize(roda_app)
        @roda_app = roda_app
      end

      def handle_routes
        instance_exec(&self.class.router_block)
      end

      # rubocop:disable Style/MissingRespondToMissing
      ruby2_keywords def method_missing(method_name, *args, &block)
        if @roda_app.respond_to?(method_name.to_sym)
          @roda_app.send method_name.to_sym, *args, &block
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @roda_app.respond_to?(method_name.to_sym, include_private) || super
      end
      # rubocop:enable Style/MissingRespondToMissing
    end
  end
end
