# frozen_string_literal: true

module Bridgetown
  module Resource
    class TaxonomyTerm
      attr_reader :resource, :label, :type

      def initialize(resource:, label:, type:)
        @resource = resource
        @label = label
        @type = type
      end

      def to_liquid
        {
          "label" => label,
        }
      end
      alias_method :to_h, :to_liquid

      def as_json(*)
        to_h
      end

      def to_json(...)
        as_json(...).to_json(...)
      end
    end
  end
end
