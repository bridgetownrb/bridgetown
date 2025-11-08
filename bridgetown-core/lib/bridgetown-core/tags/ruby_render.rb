# frozen_string_literal: true

module Bridgetown
  module Tags
    class RubyRender < Liquid::Tag
      # @param tag_name [String] "ruby_render"
      # @param ruby_expression [String] The input to the tag
      # @param tokens [Hash] A hash of config tokens for Liquid
      def initialize(tag_name, ruby_expression, tokens)
        super
        @ruby_expression = ruby_expression
      end

      # @param context [Liquid::Context]
      # @return [String]
      def render(context)
        view_context = Bridgetown::RubyTemplateView.new(context.registers[:resource])
        result = eval(@ruby_expression) # rubocop:disable Security/Eval

        if result.respond_to?(:render_in)
          result.render_in(view_context)
        else
          result.to_s
        end
      end
    end
  end
end

Liquid::Template.register_tag("ruby_render", Bridgetown::Tags::RubyRender)
