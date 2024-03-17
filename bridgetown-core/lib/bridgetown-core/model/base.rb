# frozen_string_literal: true

require "active_model"

module Bridgetown
  module Model
    class Base
      include ActiveModel::Model
      extend ActiveModel::Callbacks # also extends with DescendantsTracker
      define_model_callbacks :load, :save, :destroy

      class << self
        def find(id, site: Bridgetown::Current.site)
          raise "A Bridgetown site must be initialized and added to Current" unless site

          origin = origin_for_id(id, site:)
          klass_for_id(id, origin:).new(origin.read)
        end

        def origin_for_id(id, site: Bridgetown::Current.site)
          scheme = URI.parse(id).scheme
          origin_klass = Origin.descendants.find do |klass|
            klass.handle_scheme?(scheme)
          end

          raise "No origin could be found for #{id}" unless origin_klass

          origin_klass.new(id, site:)
        end

        def klass_for_id(id, origin: nil)
          Bridgetown::Model::Base.descendants.find do |klass|
            klass.will_load_id?(id, origin:)
          end || Bridgetown::Model::Base
        end

        def will_load_id?(id, origin: nil)
          origin ||= origin_for_id(id)
          origin.verify_model?(self)
        end

        # @param builder [Bridgetown::Builder]
        def build(builder, collection_name, path, data)
          site = builder.site
          data = Bridgetown::Model::BuilderOrigin.new(
            Bridgetown::Model::BuilderOrigin.id_for_builder_path(builder, path),
            site:
          ).read do
            data[:_collection_] = site.collections[collection_name]
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

      def origin=(new_origin)
        attributes[:_id_] = new_origin.id
        attributes[:_origin_] = new_origin
      end

      def persisted?
        (id && origin&.exists?) == true
      end

      def save
        unless origin.respond_to?(:write)
          raise "`#{origin.class}' doesn't allow writing of model objects"
        end

        run_callbacks :save do
          origin.write(self)
        end
      end

      # @return [Bridgetown::Resource::Base]
      def to_resource
        Bridgetown::Resource::Base.new(model: self)
      end

      # @return [Bridgetown::Resource::Base]
      def as_resource_in_collection
        collection.add_resource_from_model(self)
      end

      # @return [Bridgetown::Resource::Base]
      def render_as_resource
        to_resource.read!.transform!
      end

      # override if need be
      # @return [Bridgetown::Site]
      def site
        origin.site
      end

      # @return [Bridgetown::Collection]
      def collection
        attributes[:_collection_]
      end

      def collection=(new_collection)
        attributes[:_collection_] = new_collection
      end

      # @return [String]
      def content
        attributes[:_content_]
      end

      def content=(new_content)
        attributes[:_content_] = new_content
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

      def method_missing(method_name, *args)
        return attributes[method_name] if attributes.key?(method_name)

        key = method_name.to_s
        if key.end_with?("=")
          key.chop!
          # attribute_will_change!(key)
          attributes[key] = args.first
          return attributes[key]
        end

        Bridgetown.logger.warn "key `#{method_name}' not found in attributes for " \
                               "#{attributes[:id].presence || "new #{self.class}"}"
        nil
      end

      def inspect
        "#<#{self.class} #{data_attributes.inspect.delete_prefix("{").delete_suffix("}")}>"
      end
    end
  end
end
