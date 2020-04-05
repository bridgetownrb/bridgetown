# frozen_string_literal: true

module Bridgetown
  module Tags
    class BlockComponentTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super

        filename, @extra_params = markup.strip.split(" ", 2)
        @component_path = "_components/#{filename.strip}.html"

        @tag_name = tag_name
      end

      def render(context)
        markdown_content = super

        site = context.registers[:site]
        converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
        markdownified_content = converter.convert(markdown_content)

        context.stack do
          context["componentcontent"] = markdownified_content
          include_params = "#{@component_path} content=componentcontent"
          include_params = "#{include_params} #{@extra_params}" if @extra_params
          include_tag = IncludeTag.parse("include", include_params, [], @parse_context)
          include_tag.render(context)
        end
      end
    end
  end
end

Liquid::Template.register_tag("component", Bridgetown::Tags::BlockComponentTag)
