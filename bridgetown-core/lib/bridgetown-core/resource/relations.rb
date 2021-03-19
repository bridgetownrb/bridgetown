# frozen_string_literal: true

module Bridgetown
  module Resource
    class Relations
      # @return [Bridgetown::Resource::Base]
      attr_reader :resource

      # @return [Bridgetown::Site]
      attr_reader :site

      # @param resource [Bridgetown::Resource::Base]
      def initialize(resource)
        @resource = resource
        @site = resource.site
      end

      # @return [HashWithDotAccess::Hash]
      def relation_schema
        resource.collection.metadata.relations
      end

      # @return [Array<String>]
      def relation_types
        types = []
        relation_schema.each do |_relation_type, collections|
          types << collections
        end
        types.uniq.flatten
      end

      # @param type [Symbol]
      # @return [Bridgetown::Resource::Base, Array<Bridgetown::Resource::Base>]
      def resources_for_type(type)
        relation_kind = kind_of_relation_for_type(type)
        return [] unless relation_kind

        case relation_kind.to_sym
        when :belongs_to
          belongs_to_relation_for_type(type)
        when :belongs_to_many
          belongs_to_many_relation_for_type(type)
        when :has_many
          has_many_relation_for_type(type)
        when :has_one
          has_one_relation_for_type(type)
        end
      end

      def method_missing(type, *args)
        return super unless type.to_s.in?(relation_types)

        resources_for_type(type)
      end

      def respond_to_missing?(type, *_args)
        type.to_s.in?(relation_types)
      end

      private

      # @param type [Symbol]
      # @return [String]
      def kind_of_relation_for_type(type)
        relation_schema.each do |relation_type, collections|
          return relation_type if collections == type.to_s || collections.include?(type.to_s)
        end
      end

      # @param type [Symbol]
      # @return [Bridgetown::Collection]
      def other_collection_for_type(type)
        site.collections[type] || site.collections[ActiveSupport::Inflector.pluralize(type)]
      end

      # @return [Array<String>]
      def collection_labels
        [
          resource.collection.label,
          ActiveSupport::Inflector.singularize(resource.collection.label),
        ]
      end

      # @param type [Symbol]
      # @return [Bridgetown::Resource::Base]
      def belongs_to_relation_for_type(type)
        other_collection_for_type(type).resources.find do |other_resource|
          other_resource.data.slug == resource.data[type]
        end
      end

      # @param type [Symbol]
      # @return [Array<Bridgetown::Resource::Base>]
      def belongs_to_many_relation_for_type(type)
        other_collection_for_type(type).resources.select do |other_resource|
          other_resource.data.slug.in?(resource.data[type])
        end
      end

      # @param type [Symbol]
      # @return [Array<Bridgetown::Resource::Base>]
      def has_many_relation_for_type(type) # rubocop:disable Naming/PredicateName
        label, singular_label = collection_labels

        other_collection_for_type(type).resources.select do |other_resource|
          resource.data.slug.in?(
            Array(other_resource.data[label] || other_resource.data[singular_label])
          )
        end
      end

      # @param type [Symbol]
      # @return [Bridgetown::Resource::Base]
      def has_one_relation_for_type(type) # rubocop:disable Naming/PredicateName
        label, singular_label = collection_labels

        other_collection_for_type(type).resources.find do |other_resource|
          resource.data.slug.in?(
            Array(other_resource.data[label] || other_resource.data[singular_label])
          )
        end
      end
    end
  end
end
