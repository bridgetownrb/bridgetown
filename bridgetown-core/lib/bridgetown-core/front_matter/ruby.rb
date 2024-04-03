# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module RubyDSL
      def front_matter(scope: nil, &block)
        RubyFrontMatter.new(scope:).tap { |fm| fm.instance_exec(&block) }
      end
    end

    class RubyFrontMatter
      def initialize(scope: nil, data: {})
        @data, @scope = data, scope
      end

      def method_missing(key, *value, &block) # rubocop:disable Metrics/CyclomaticComplexity, Style/MissingRespondToMissing
        return super if respond_to?(key) || (value.empty? && block.nil? && !@data.key?(key))

        return get(key) if value.empty? && block.nil? && @data.key?(key)

        set(key, value[0], &block)
      end

      def each(&)
        @data.each(&)
      end

      def get(key)
        @data[key]
      end

      def set(key, value = nil, &block)
        # Handle nested data within a block
        if block
          value = self.class.new(scope: @scope).tap do |fm|
            fm.instance_exec(&block)
          end.to_h
        end

        # Execute lambda value within the resolver
        if @scope && value.is_a?(Hash) && value[:from].is_a?(Proc)
          value = @scope.instance_exec(&value[:from])
        end

        @data[key] = value
      end

      def to_h
        @data
      end
    end
  end
end
