# frozen_string_literal: true

module Bridgetown
  module Resource
    class TaxonomyTerm
      attr_reader :resource

      attr_reader :label

      attr_reader :type

      def initialize(resource:, label:, type:)
        @resource = resource
        @label = label
        @type = type
      end

      def to_liquid
        label
      end
    end
  end
end
