# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyFrontMatterDSL
      def front_matter(&block)
        RubyFrontMatter.new.tap { |fm| fm.instance_exec(&block) }
      end
    end

    class RubyFrontMatter
      def initialize
        @data = {}
      end

      def method_missing(key, value) # rubocop:disable Style/MissingRespondToMissing
        return super if respond_to?(key)

        @data[key] = value
      end

      def to_h
        @data
      end
    end
  end
end
