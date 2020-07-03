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
      # Does the given extension match this converter's list of acceptable extensions?
      # Takes one argument: the file's extension (including the dot).
      #
      # ext - The String extension to check.
      #
      # Returns true if it matches, false otherwise.
      def matches(ext)
        ext.casecmp(".erb").zero?
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
