# frozen_string_literal: true

module Bridgetown
  module Filters
    module GroupingFilters
      # Group an array of items by a property, returning an array of hashes
      #
      # @example
      #   {"name"  => "larry"
      #    "items" => [...] } # all the items where `property` == "larry"
      #
      # @param input [Enumerable]
      # @param property [String]
      # @return [Array<Hash>]
      def group_by(input, property)
        if groupable?(input)
          groups = input.group_by { |item| item_property(item, property).to_s }
          grouped_array(groups)
        else
          input
        end
      end

      # Group an array of items by an expression
      #
      # @param input [Enumerable]
      # @param variable [String] variable to assign each item to in the expression
      # @param expression [String] Liquid comparison expression
      # @return [Array<Hash>]
      def group_by_exp(input, variable, expression)
        return input unless groupable?(input)

        parsed_expr = parse_expression(expression)
        @context.stack do
          groups = input.group_by do |item|
            @context[variable] = item
            parsed_expr.render(@context)
          end
          grouped_array(groups)
        end
      end

      private

      def parse_expression(str)
        Liquid::Variable.new(str, Liquid::ParseContext.new)
      end

      def groupable?(element)
        element.respond_to?(:group_by)
      end

      def grouped_array(groups)
        groups.each_with_object([]) do |item, array|
          array << {
            "name"  => item.first,
            "items" => item.last,
            "size"  => item.last.size,
          }
        end
      end
    end
  end
end
