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
        {
          "label" => label,
        }
      end
      alias_method :to_h, :to_liquid

      def as_json(*)
        to_h
      end

      ruby2_keywords def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end
