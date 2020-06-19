# frozen_string_literal: true

require "erb"
require "active_support/core_ext/hash/keys"

module Bridgetown
  class ERBView
    include ERB::Util

    attr_reader :layout, :page, :site, :content
    def initialize(convertible)
      if convertible.is_a?(Layout)
        @layout = convertible
        @page = layout.current_document
        @content = layout.current_document_output
      else
        @page = convertible
      end
      @site = page.site
    end

    def render(component, options = {})
      render_statement = _render_statement(component, options).join

      template = site.liquid_renderer.file(
        "#{page.path}#{render_statement.hash}"
      ).parse(render_statement)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(options.deep_stringify_keys, _liquid_context)
    end

    def markdownify
      @_erbout, _buf_was = +"", @_erbout
      result = yield
      @_erbout = _buf_was

      content = Bridgetown::Utils.reindent_for_markdown(result)
      converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
      converter.convert(content).strip
    end

    def site_drop
      site.site_payload.site
    end

    def _local_binding
      binding
    end

    private

    def _render_statement(component, options)
      render_statement = ["{% render \"#{component}\""]
      unless options.empty?
        render_statement << ", " + options.keys.map { |k| "#{k}: #{k}" }.join(", ")
      end
      render_statement << " %}"
    end

    def _liquid_context
      {
        registers: {
          site: site,
          page: page,
          cached_partials: Bridgetown::Renderer.cached_partials,
        },
        strict_filters: site.config["liquid"]["strict_filters"],
        strict_variables: site.config["liquid"]["strict_variables"],
      }
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
        erb_renderer = ERB.new(content, trim_mode: "<>-", eoutvar: "@_erbout")

        if convertible.is_a?(Bridgetown::Layout)
          erb_renderer.result(erb_view._local_binding do
            convertible.current_document_output
          end)
        else
          erb_renderer.result(erb_view._local_binding)
        end
      end
    end
  end
end
