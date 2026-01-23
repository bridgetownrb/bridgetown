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
      end

      # @param context [Liquid::Context]
      # @return [String]
      def render(context)
        view_context = Bridgetown::RubyTemplateView.new(context.registers[:resource])
        component_class_name_snakecase, _, component_initialize_args =
          @input.partition(%r{,\s*})
        component_class_name = component_class_name_snakecase.tr("\"'", "").camelize.strip
        component_class = self.class.const_get(component_class_name)
        ruby_expression = "#{component_class}.new(#{component_initialize_args})"
        component_instance = eval(ruby_expression, binding, __FILE__, __LINE__) # rubocop:disable Security/Eval

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
