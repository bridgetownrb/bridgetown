# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyFrontMatterDSL
      def front_matter(eval_with: nil, &block)
        RubyFrontMatter.new(eval_with: eval_with).tap { |fm| fm.instance_exec(&block) }
      end
    end

    class RubyFrontMatter
      def initialize(eval_with: nil)
        @data = {}
        @eval_with = eval_with
      end

      def method_missing(key, value = nil, &block) # rubocop:disable Metrics/CyclomaticComplexity, Style/MissingRespondToMissing
        return super if respond_to?(key) || (value.nil? && block.nil? && !@data.key?(key))

        return get(key) if value.nil? && block.nil? && @data.key?(key)

        set(key, value, &block)
      end

      def each(&block)
        @data.each(&block)
      end

      def get(key)
        @data[key]
      end

      def set(key, value = nil, &block)
        # Handle nested data within a block
        if block
          value = self.class.new(eval_with: @eval_with).tap do |fm|
            fm.instance_exec(&block)
          end.to_h
        end

        # Execute lambda value within the resolver
        if @eval_with && value.is_a?(Hash) && value[:eval].is_a?(Proc)
          value = @eval_with.instance_exec(&value[:eval])
        end

        @data[key] = value
      end

      def to_h
        @data
      end
    end
  end
end
