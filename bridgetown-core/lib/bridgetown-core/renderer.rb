# frozen_string_literal: true

module Bridgetown
  # This class handles the output rendering and layout placement of pages and
  # documents. For rendering of resources in particular, see Bridgetown::Resource::Transformer
  class Renderer
    attr_reader :document, :site

    def initialize(site, document)
      @site     = site
      @document = document
    end

    # Determine which converters to use based on this document's
    # extension.
    #
    # Returns Array of Converter instances.
    def converters
      @converters ||= site.converters.select do |converter|
        if converter.method(:matches).arity == 1
          converter.matches(document.extname)
        else
          converter.matches(document.extname, document)
        end
      end.sort
    end

    # Determine the extname the outputted file should have
    #
    # Returns String the output extname including the leading period.
    def output_ext
      @output_ext ||= (permalink_ext || converter_output_ext)
    end

    # Run hooks and render the document
    #
    # Returns nothing
    def run
      Bridgetown.logger.debug "Rendering:", document.relative_path

      document.trigger_hooks :pre_render
      document.output = render_document
      document.trigger_hooks :post_render
    end

    # Render the document.
    #
    # Returns String rendered document output
    def render_document
      execute_inline_ruby!

      output = document.content
      Bridgetown.logger.debug "Rendering Markup:", document.relative_path
      output = convert(output.to_s, document)
      document.content = output.html_safe

      if document.place_in_layout?
        Bridgetown.logger.debug "Rendering Layout:", document.relative_path
        output = place_in_layouts(output)
      end

      output
    end

    def execute_inline_ruby!
      return unless site.config.should_execute_inline_ruby?

      Bridgetown::Utils::RubyExec.search_data_for_ruby_code(document)
    end

    # Convert the document using the converters which match this renderer's document.
    #
    # Returns String the converted content.
    def convert(content, document)
      converters.reduce(content) do |output, converter|
        if converter.method(:convert).arity == 1
          converter.convert output
        else
          converter.convert output, document
        end
      rescue StandardError => e
        Bridgetown.logger.error "Conversion error:",
                                "#{converter.class} encountered an error while "\
                                "converting `#{document.relative_path}'"
        raise e
      end
    end

    # Render layouts and place document content inside.
    #
    # Returns String rendered content
    def place_in_layouts(content)
      output = content.dup
      layout = site.layouts[document.data["layout"]]
      validate_layout(layout)

      used = Set.new([layout])

      while layout
        output = render_layout(output, layout)

        next unless (layout = site.layouts[layout.data["layout"]])
        break if used.include?(layout)

        used << layout
      end
      output
    end

    private

    # Checks if the layout specified in the document actually exists
    #
    # layout - the layout to check
    # Returns nothing
    def validate_layout(layout)
      return unless document.data["layout"].present? &&
        layout.nil? &&
        !(document.is_a? Bridgetown::Excerpt)

      Bridgetown.logger.warn "Build Warning:", "Layout '#{document.data["layout"]}' requested " \
                                               "in #{document.relative_path} does not exist."
    end

    # Render layout content into document.output
    #
    # Returns String rendered content
    def render_layout(output, layout)
      layout_converters = site.matched_converters_for_convertible(layout)

      layout_content = layout.content.dup
      layout_converters.reduce(layout_content) do |layout_output, converter|
        next(layout_output) unless converter.method(:convert).arity == 2

        layout.current_document = document
        layout.current_document_output = output
        converter.convert layout_output, layout
      rescue StandardError => e
        Bridgetown.logger.error "Conversion error:",
                                "#{converter.class} encountered an error while "\
                                "converting `#{document.relative_path}'"
        raise e
      end
    end

    def permalink_ext
      document_permalink = document.permalink
      if document_permalink &&
          !document_permalink.end_with?("/")
        permalink_ext = File.extname(document_permalink)
        permalink_ext unless permalink_ext.empty?
      end
    end

    def converter_output_ext
      if output_exts.size == 1
        output_exts.last
      else
        output_exts[-2]
      end
    end

    def output_exts
      @output_exts ||= converters.map do |c|
        c.output_ext(document.extname)
      end.compact
    end
  end
end
