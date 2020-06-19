# frozen_string_literal: true

require "tilt/haml"

module Bridgetown
  class HamlView < RubyTemplateView
    def partial_render(partial_name, options = {})
      Tilt::HamlTemplate.new(
        site.in_source_dir("_partials", "#{partial_name}.haml")
      ).render(self, options)
    end
  end

  module Converters
    class HamlTemplates < Converter
      # Does the given extension match this converter's list of acceptable extensions?
      # Takes one argument: the file's extension (including the dot).
      #
      # ext - The String extension to check.
      #
      # Returns true if it matches, false otherwise.
      def matches(ext)
        ext.casecmp(".haml").zero?
      end

      # Public: The extension to be given to the output file (including the dot).
      #
      # ext - The String extension or original file.
      #
      # Returns The String output file extension.
      def output_ext(_ext)
        ".html"
      end

      # Logic to do the content conversion.
      #
      # content - String content of file (without front matter).
      #
      # Returns a String of the converted content.
      def convert(content, convertible)
        haml_view = Bridgetown::HamlView.new(convertible)

        haml_renderer = Tilt::HamlTemplate.new { content }

        if convertible.is_a?(Bridgetown::Layout)
          haml_renderer.render(haml_view) do
            convertible.current_document_output
          end
        else
          haml_renderer.render(haml_view)
        end
      end
    end
  end
end
