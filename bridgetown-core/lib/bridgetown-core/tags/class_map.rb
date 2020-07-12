# frozen_string_literal: true

require "set"

module Bridgetown
  module Tags
    # A ClassMap class is meant to take a hash and append styles based on if the
    # value is truthy or falsy
    #
    # @example
    #   center-var = true
    #   small-var = nil
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
    class ClassMap < Liquid::Tag
      # @see https://api.rubyonrails.org/classes/ActiveModel/Type/Boolean.html
      FALSE_VALUES = [
        nil, "nil", "NIL", false, 0, "0", :"0", "f", :f, "F", :F, "false",
        false, "FALSE", :FALSE,
      ].to_set.freeze

      # @param tag_name [String] The name to use for the tag
      # @param input [String] The input to the tag
      # @param tokens [Hash] A hash of config tokens for Liquid.
      #
      #
      # @return [ClassMap] Returns a ClassMap object
      def initialize(tag_name, input, tokens)
        super
        @input = input
      end

      def render(context)
        to_class_ary(@input, context).join(" ")
      end

      private

      def to_class_ary(string, context)
        ary = []

        string.split(%r!,\s+!).each do |item|
          kv_pair = item.split(%r!:\s+!)
          klass = kv_pair[0]
          variable = kv_pair[1]
          variable = find_variable(context, variable)
          ary.push(klass) unless FALSE_VALUES.include?(variable)
        end

        ary
      end

      def find_variable(context, variable)
        lookup = context

        variable.split(".").each do |value|
          lookup = lookup[value.strip]
        end

        lookup || nil
      end
    end
  end
end

Liquid::Template.register_tag("class_map", Bridgetown::Tags::ClassMap)
