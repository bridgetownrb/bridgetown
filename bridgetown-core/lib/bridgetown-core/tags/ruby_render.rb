# frozen_string_literal: true

module Bridgetown
  module Tags
    class RubyRender < Liquid::Tag
      using Bridgetown::Refinements

      # @param tag_name [String] "ruby_render"
      # @param input [String] The input to the tag: snake-case name of the
      #   Ruby component, plus initialize args. Example:
      #     '"card", title: "Hello", footer: "I am a card"'
      # @param tokens [Hash] A hash of config tokens for Liquid
      def initialize(tag_name, input, tokens)
        super
        @input = input

        @attributes = {}
        input.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key.to_sym] = parse_expression(value)
        end
      end

      # @param context [Liquid::Context]
      # @return [String]
      def render(context)
        view_context = Bridgetown::RubyTemplateView.new(context.registers[:resource])
        component_class_name_snakecase = @input.split(",").first
        component_class_name = component_class_name_snakecase.tr("\"'", "").camelize.strip
        component_class = self.class.const_get(component_class_name)
        @attributes.each do |key, value|
          @attributes[key] = value.evaluate(context) if value.is_a?(Liquid::VariableLookup)
        end
        component_instance = component_class.new(**@attributes)

        if component_instance.respond_to?(:render_in)
          component_instance.render_in(view_context)
        else
          component_instance.to_s
        end
      end
    end
  end
end

Liquid::Template.register_tag("ruby_render", Bridgetown::Tags::RubyRender)
