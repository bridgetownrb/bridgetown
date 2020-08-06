# frozen_string_literal: true

require "tilt/erubi"
require "erubi/capture_end"

module Bridgetown
  class ERBView < RubyTemplateView
    def h(input)
      Erubi.h(input)
    end

    def partial(partial_name, options = {})
      options.merge!(options[:locals]) if options[:locals]

      partial_segments = partial_name.split("/")
      partial_segments.last.sub!(%r!^!, "_")
      partial_name = partial_segments.join("/")

      Tilt::ErubiTemplate.new(
        site.in_source_dir(site.config[:partials_dir], "#{partial_name}.erb"),
        outvar: "@_erbout",
        engine_class: Erubi::CaptureEndEngine
      ).render(self, options)
    end

    def markdownify
      previous_buffer_state = @_erbout
      @_erbout = +""
      result = yield
      @_erbout = previous_buffer_state

      content = Bridgetown::Utils.reindent_for_markdown(result)
      converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
      md_output = converter.convert(content).strip
      @_erbout << md_output
    end

    def capture
      previous_buffer_state = @_erbout
      @_erbout = +""
      result = yield
      @_erbout = previous_buffer_state

      result
    end
  end

  module Converters
    class ERBTemplates < Converter
      input :erb

      # Logic to do the ERB content conversion.
      #
      # @param content [String] Content of the file (without front matter).
      # @params convertible [Bridgetown::Page, Bridgetown::Document, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      #
      # @return [String] The converted content.
      def convert(content, convertible)
        erb_view = Bridgetown::ERBView.new(convertible)

        erb_renderer = Tilt::ErubiTemplate.new(
          convertible.relative_path,
          outvar: "@_erbout",
          engine_class: Erubi::CaptureEndEngine
        ) { content }

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
