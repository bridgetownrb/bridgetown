# frozen_string_literal: true
require 'json'

module Bridgetown
  module Tags
    class ClassMap < Liquid::Tag
      # @param tag_name [String] The name to use for the tag
      # @param input [String] The input to the tag
      # @param token [Hash] A hash of config tokens for Liquid.
      #
      # @example
      #   center-var = true
      #   is-small = nil
      #
      #   # input
      #   <div class="{% class_map has-centered-text: center-var, is-small: small-var %}">
      #     Text
      #   </div>
      #
      #   # output
      #   <div class="has-centered-text">
      #     Text
      #   </div>
      #
      # @return [ClassMap] Returns a ClassMap object
      def initialize(tag_name, input, tokens)
        super

        @hash = JSON.parse(input.strip.to_json)
      end

      def render(context)
        evaluate_variables(context)
        @hash.map { |key, variable| key if variable }.compact.join(" ")
      end

      private

      # @param context [Liquid::Context] The context to run the variable in
      # @return [Hash] Returns a hash with updated variables
      def evaluate_variables(context)
        @hash.transform_values! do |value|
          lookup = context

          variable.split(".").each { |value| lookup = lookup[value] }

          lookup || false
        end
      end
    end
  end
end
