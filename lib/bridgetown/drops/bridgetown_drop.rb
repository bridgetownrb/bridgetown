# frozen_string_literal: true

module Bridgetown
  module Drops
    class BridgetownDrop < Liquid::Drop
      class << self
        def global
          @global ||= BridgetownDrop.new
        end
      end

      def version
        Bridgetown::VERSION
      end

      def environment
        Bridgetown.env
      end

      def to_h
        @to_h ||= {
          "version"     => version,
          "environment" => environment,
        }
      end

      def to_json(state = nil)
        JSON.generate(to_h, state)
      end
    end
  end
end
