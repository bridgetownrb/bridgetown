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
        class_map(@input, context)
      end

      private

      def class_map(string, context)
        ary = []

        string.split(%r!,\s+!).each do |item|
          kv_pair = item.split(%r!:\s+!)
          klass = kv_pair[0]
          variable = kv_pair[1]

          # Check if a user wants the opposite of the variable
          if variable[0] == "!"
            check_opposite = true
            variable.slice!(1..-1)
          end

          variable = find_variable(context, variable)

          if check_opposite
            ary.push(klass) if FALSE_VALUES.include?(variable)
          else
            ary.push(klass) unless FALSE_VALUES.include?(variable)
          end
        end

        ary.join(" ")

      # Gracefully handle if syntax is improper
      rescue NoMethodError
        "invalid-class-map"
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
