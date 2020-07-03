# frozen_string_literal: true

require "tilt/erb"
require "active_support/core_ext/hash/keys"

module Bridgetown
  class ERBView < RubyTemplateView
    include ERB::Util

    def partial_render(partial_name, options = {})
      Tilt::ERBTemplate.new(
        site.in_source_dir(site.config[:partials_dir], "#{partial_name}.erb"),
        trim: "<>-",
        outvar: "@_erbout"
      ).render(self, options)
    end

    def markdownify
      previous_buffer_state = @_erbout
      @_erbout = +""
      result = yield
      @_erbout = previous_buffer_state

      content = Bridgetown::Utils.reindent_for_markdown(result)
      converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
      converter.convert(content).strip
    end
  end

  module Converters
    class ERBTemplates < Converter
      input :erb

      # Logic to do the content conversion.
      #
      # content - String content of file (without front matter).
      #
      # Returns a String of the converted content.
      def convert(content, convertible)
        erb_view = Bridgetown::ERBView.new(convertible)

        erb_renderer = Tilt::ERBTemplate.new(trim: "<>-", outvar: "@_erbout") { content }

        if convertible.is_a?(Bridgetown::Layout)
          erb_renderer.render(erb_view) do
            convertible.current_document_output
          end
        else
          erb_renderer.render(erb_view)
        end
      end
    end
  end
end
