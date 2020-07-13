# frozen_string_literal: true

module Bridgetown
  module Filters
    module ConditionHelpers
      # -----------   The following set of code was *adapted* from Liquid::If
      # -----------   ref: https://git.io/vp6K6

      # Parse a string to a Liquid Condition
      def parse_condition(exp)
        parser    = Liquid::Parser.new(exp)
        condition = parse_binary_comparison(parser)

        parser.consume(:end_of_string)
        condition
      end

      # Generate a Liquid::Condition object from a Liquid::Parser object additionally processing
      # the parsed expression based on whether the expression consists of binary operations with
      # Liquid operators `and` or `or`
      #
      #  - parser: an instance of Liquid::Parser
      #
      # Returns an instance of Liquid::Condition
      def parse_binary_comparison(parser)
        condition = parse_comparison(parser)
        first_condition = condition
        while (binary_operator = parser.id?("and") || parser.id?("or"))
          child_condition = parse_comparison(parser)
          condition.send(binary_operator, child_condition)
          condition = child_condition
        end
        first_condition
      end

      # Generates a Liquid::Condition object from a Liquid::Parser object based on whether the parsed
      # expression involves a "comparison" operator (e.g. <, ==, >, !=, etc)
      #
      #  - parser: an instance of Liquid::Parser
      #
      # Returns an instance of Liquid::Condition
      def parse_comparison(parser)
        left_operand = Liquid::Expression.parse(parser.expression)
        operator     = parser.consume?(:comparison)

        # No comparison-operator detected. Initialize a Liquid::Condition using only left operand
        return Liquid::Condition.new(left_operand) unless operator

        # Parse what remained after extracting the left operand and the `:comparison` operator
        # and initialize a Liquid::Condition object using the operands and the comparison-operator
        Liquid::Condition.new(left_operand, operator, Liquid::Expression.parse(parser.expression))
      end
    end
  end
end
