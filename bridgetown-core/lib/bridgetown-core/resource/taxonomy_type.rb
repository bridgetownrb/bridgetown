# frozen_string_literal: true

module Bridgetown
  module Resource
    class TaxonomyType
      # @return [Bridgetown::Site]
      attr_reader :site

      # @return [String] aka `category`, `tag`, `region`, etc.
      attr_reader :label

      # @return [String] the key used in front matter
      attr_reader :key

      # @return [HashWithDotAccess::Hash] any associated metadata
      attr_reader :metadata

      # @param site [Bridgetown::Site]
      # @param label [String]
      # @param key [String]
      def initialize(site:, label:, key:, metadata:)
        @site = site
        @label = label
        @key = key
        @metadata = metadata
      end

      def terms
        site.resources.map do |resource|
          resource.taxonomies[label].terms
        end.flatten.group_by(&:label).with_dot_access
      end

      def inspect
        "#<#{self.class} label=#{label}>"
      end

      def to_liquid
        {
          "label"    => label,
          "key"      => key,
          "metadata" => metadata,
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
