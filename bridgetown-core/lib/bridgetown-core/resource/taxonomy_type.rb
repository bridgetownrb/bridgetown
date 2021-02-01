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

      # @param site [Bridgetown::Site]
      # @param label [String]
      # @param key [String]
      def initialize(site:, label:, key:)
        @site = site
        @label = label
        @key = key
      end

      def terms
        site.resources.map do |resource|
          resource.taxonomies[label].terms
        end.flatten.group_by(&:label).with_dot_access
      end

      def inspect
        "#<#{self.class} label=#{label}>"
      end
    end
  end
end
