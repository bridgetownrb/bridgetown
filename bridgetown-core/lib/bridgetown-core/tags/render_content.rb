# frozen_string_literal: true

module Bridgetown
  module Tags
    class BlockRenderTag < Liquid::Block
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def render(context)
        context.stack({}) do
          # unindent the incoming text
          content = Bridgetown::Utils.reindent_for_markdown(super)

          regions = gather_content_regions(context)

          site = context.registers[:site]
          converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
          markdownified_content = converter.convert(content)
          context["processed_component_content"] = markdownified_content

          render_params = [@markup, "content: processed_component_content"]
          unless regions.empty?
            regions.each do |region_name, region_content|
              region_name = region_name.sub("content_with_region_", "")

              if region_name.end_with? ":markdown"
                region_name.sub!(%r!:markdown$!, "")
                context[region_name] = converter.convert(
                  Bridgetown::Utils.reindent_for_markdown(region_content)
                )
              else
                context[region_name] = region_content
              end
              render_params.push "#{region_name}: #{region_name}"
            end
          end

          Liquid::Render.parse("render", render_params.join(","), nil, @parse_context)
            .render_tag(context, +"")
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def gather_content_regions(context)
        unless context.scopes[0].keys.find { |k| k.to_s.start_with? "content_with_region_" }
          return {}
        end

        context.scopes[0].select { |k| k.to_s.start_with? "content_with_region_" }
      end
    end
  end
end

Liquid::Template.register_tag("rendercontent", Bridgetown::Tags::BlockRenderTag)
