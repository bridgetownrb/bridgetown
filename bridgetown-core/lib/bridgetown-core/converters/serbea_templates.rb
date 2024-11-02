# frozen_string_literal: true

require "serbea"
require "rouge/lexers/serbea"

module Bridgetown
  class SerbeaView < ERBView
    include Serbea::Helpers

    def _render_partial(partial_name, options)
      partial_path = _partial_path(partial_name, "serb")
      site.tmp_cache["partial-tmpl:#{partial_path}"] ||= {
        signal: site.config.fast_refresh ? Signalize.signal(1) : nil,
      }
      tmpl = site.tmp_cache["partial-tmpl:#{partial_path}"]
      tmpl.template ||= Tilt::SerbeaTemplate.new(partial_path)
      tmpl.signal&.value # subscribe so resources are attached to this partial within effect
      tmpl.template.render(self, options)
    end
  end

  module Converters
    class SerbeaTemplates < Converter
      priority :highest
      template_engine :serbea
      input :serb

      # Logic to do the Serbea content conversion
      #
      # @param content [String] Content of the file (without front matter)
      # @param convertible [
      #   Bridgetown::GeneratedPage, Bridgetown::Resource::Base, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      # @return [String] The converted content
      def convert(content, convertible)
        serb_view = Bridgetown::SerbeaView.new(convertible)
        serb_renderer = Tilt::SerbeaTemplate.new(
          convertible.path,
          line_start(convertible)
        ) { content }

        if convertible.is_a?(Bridgetown::Layout)
          serb_renderer.render(serb_view) do
            convertible.current_document_output
          end
        else
          serb_renderer.render(serb_view)
        end
      end
    end
  end
end
