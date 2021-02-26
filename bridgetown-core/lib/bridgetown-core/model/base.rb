# frozen_string_literal: true

require "active_model"

module Bridgetown
  module Model
    class Base
      include ActiveModel::Model
      extend ActiveModel::Callbacks
      define_model_callbacks :save, :destroy

      def self.find(id)
        raise "A Bridgetown site must be initialized and added to Current" unless Current.site

        new(read_data_for_id(id))
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

      def to_resource
        Bridgetown::Resource::Base.new(model: self)
      end

      # override if need be
      # @return [Bridgetown::Site]
      def site
        Current.site
      end

      def attributes
        @attributes ||= HashWithDotAccess::Hash.new
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
    end
  end
end
