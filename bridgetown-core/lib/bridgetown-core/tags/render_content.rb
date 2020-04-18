# frozen_string_literal: true

module Bridgetown
  module Tags
    class BlockRenderTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super

        @tag = tag_name
        @markup = markup
        @options = options
      end

      def render(context)
        content = super.gsub(%r!^[ \t]+!, "") # unindent the incoming text

        site = context.registers[:site]
        converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
        markdownified_content = converter.convert(content)

        context.stack do
          context["componentcontent"] = markdownified_content
          render_params = "#{@markup}, content: componentcontent"
          render_tag = Liquid::Render.parse("render", render_params, @options, @parse_context)
          render_tag.render_tag(context, +"")
        end
      end
    end
  end
end

Liquid::Template.register_tag("rendercontent", Bridgetown::Tags::BlockRenderTag)
