# frozen_string_literal: true

module Bridgetown
  module Resource
    class Taxonomy
      attr_accessor :label

      def initialize(label:)
        @label = label
      end
    end
  end
end
