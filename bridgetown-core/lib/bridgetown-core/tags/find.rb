# frozen_string_literal: true

module Bridgetown
  module Tags
    class Find < Liquid::Tag
      include Bridgetown::Filters::ConditionHelpers
      include Bridgetown::LiquidExtensions

      SYNTAX = %r!^(.*?) (where|in) (.*?),(.*)$!
      CONDITIONS_SEP = "~FINDSEP~"

      def initialize(tag_name, markup, tokens)
        super
        unless markup.strip =~ SYNTAX
          raise SyntaxError, <<~MSG
            Syntax Error in tag 'find' while parsing the following markup:

            #{markup}

            Valid syntax: find <varname> where|in <array>, <condition(s)>
          MSG
        end

        @new_var_name = Regexp.last_match(1).strip
        @single_or_group = Regexp.last_match(2)
        @arr_name = Regexp.last_match(3).strip
        @conditions = process_conditions(Regexp.last_match(4).strip)
      end

      def render(context)
        @group = lookup_variable(context, @arr_name)
        return "" unless @group.respond_to?(:select)

        @group = @group.values if @group.is_a?(Hash)

        expression = @conditions.split(CONDITIONS_SEP).map do |condition|
          "__find_tag_item__.#{condition.strip}"
        end.join(" and ")
        @liquid_condition = parse_condition(expression)

        context[@new_var_name] = if @single_or_group == "where"
                                   group_evaluate(context)
                                 else
                                   single_evaluate(context)
                                 end

        ""
      end

      private

      def process_conditions(conditions)
        processed_conditions = +""
        in_quotes = false

        conditions.each_char do |c|
          in_quotes = !in_quotes if c == '"'

          processed_conditions << (c == "," && !in_quotes ? CONDITIONS_SEP : c)
        end

        processed_conditions
      end

      def group_evaluate(context)
        context.stack do
          @group.select do |object|
            context["__find_tag_item__"] = object
            @liquid_condition.evaluate(context)
          end
        end || []
      end

      def single_evaluate(context)
        context.stack do
          @group.find do |object|
            context["__find_tag_item__"] = object
            @liquid_condition.evaluate(context)
          end
        end || nil
      end
    end
  end
end

Liquid::Template.register_tag("find", Bridgetown::Tags::Find)
