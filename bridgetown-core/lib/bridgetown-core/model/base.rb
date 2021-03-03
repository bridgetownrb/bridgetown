# frozen_string_literal: true

require "active_model"

module Bridgetown
  module Model
    class Base
      include ActiveModel::Model
      extend ActiveModel::Callbacks # also extends with DescendantsTracker
      define_model_callbacks :load, :save, :destroy

      def self.loads_id?(id)
        name == ActiveSupport::Inflector.classify(
          URI.parse(id).host.chomp(".collection")
        )
      end

      def self.find(id)
        unless Bridgetown::Current.site
          raise "A Bridgetown site must be initialized and added to Current"
        end

        model_klass = klass_for_id(id)
        model_klass.new(read_data_for_id(id))
      end

      def self.klass_for_id(id)
        descendants.find do |klass|
          klass.loads_id?(id)
        end || self
      end

      def self.read_data_for_id(id)
        origin_for_id(id).read
      end

      def self.origin_for_id(id)
        scheme = URI.parse(id).scheme
        origin_klass = Origin.descendants.find do |klass|
          klass.handle_scheme?(scheme)
        end

        raise "No origin could be found for #{id}" unless origin_klass

        origin_klass.new(id)
      end

      class << self
        ruby2_keywords def build(collection_name, path, data = {})
          data = Bridgetown::Model::BuilderOrigin.new("builder://#{path}").read do
            data[:_collection_] = Bridgetown::Current.site.collections[collection_name]
            data
          end
          new(data)
        end
      end

      def initialize(attributes = {})
        run_callbacks :load do
          super
        end
      end

      def id
        attributes[:id] || attributes[:_id_]
      end

      # @return [Bridgetown::Model::Origin]
      def origin
        attributes[:_origin_]
      end

      def persisted?
        id && origin.exists?
      end

      # @return [Bridgetown::Resource::Base]
      def to_resource
        Bridgetown::Resource::Base.new(model: self)
      end

      def as_resource_in_collection
        collection.resources << to_resource.read!
        collection.resources.last
      end

      # override if need be
      # @return [Bridgetown::Site]
      def site
        Bridgetown::Current.site
      end

      # @return [Bridgetown::Collection]
      def collection
        attributes[:_collection_]
      end

      # @return [String]
      def content
        attributes[:_content_]
      end

      def attributes
        @attributes ||= HashWithDotAccess::Hash.new
      end

      # Strip out keys like _origin_, _collection_, etc.
      # @return [HashWithDotAccess::Hash]
      def data_attributes
        attributes.reject { |k| k.starts_with?("_") && k.ends_with?("_") }
      end

      def respond_to_missing?(method_name, include_private = false)
        attributes.key?(method_name) || method_name.to_s.end_with?("=") || super
      end

      def method_missing(method_name, *args) # rubocop:disable Style/MethodMissingSuper
        return attributes[method_name] if attributes.key?(method_name)

        key = method_name.to_s
        if key.end_with?("=")
          key.chop!
          # attribute_will_change!(key)
          attributes[key] = args.first
          return attributes[key]
        end

        Bridgetown.logger.warn "key `#{method_name}' not found in attributes for" \
                               " #{attributes[:id].presence || ("new " + self.class.to_s)}"
        nil
      end

      def inspect
        "#<#{self.class} #{data_attributes.inspect.delete_prefix("{").delete_suffix("}")}>"
      end
    end
  end
end
