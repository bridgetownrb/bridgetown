# frozen_string_literal: true

module Bridgetown
  class Renderer
    attr_reader :document, :site
    attr_writer :layouts, :payload

    class << self
      attr_accessor :cached_partials
    end

    def initialize(site, document, site_payload = nil)
      @site     = site
      @document = document
      @payload  = site_payload
      @layouts  = nil
      self.class.cached_partials ||= {}
    end

    # Fetches the payload used in Liquid rendering.
    # It can be written with #payload=(new_payload)
    # Falls back to site.site_payload if no payload is set.
    #
    # Returns a Bridgetown::Drops::UnifiedPayloadDrop
    def payload
      @payload ||= site.site_payload
    end

    # The list of layouts registered for this Renderer.
    # It can be written with #layouts=(new_layouts)
    # Falls back to site.layouts if no layouts are registered.
    #
    # Returns a Hash of String => Bridgetown::Layout identified
    # as basename without the extension name.
    def layouts
      @layouts || site.layouts
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

    # Prepare payload and render the document
    #
    # Returns nothing
    def run
      Bridgetown.logger.debug "Rendering:", document.relative_path

      assign_pages!
      # TODO: this can be eliminated I think:
      assign_current_document!
      assign_highlighter_options!
      assign_layout_data!

      document.trigger_hooks(:pre_render, payload)
      document.output = render_document
      document.trigger_hooks(:post_render)
    end

    # Render the document.
    #
    # Returns String rendered document output
    # rubocop: disable Metrics/AbcSize
    def render_document
      liquid_context = nil

      execute_inline_ruby!

      output = document.content
      if document.render_with_liquid?
        liquid_context = provide_liquid_context
        Bridgetown.logger.debug "Rendering Liquid:", document.relative_path
        output = render_liquid(output, payload, liquid_context, document.path)
      end

      Bridgetown.logger.debug "Rendering Markup:", document.relative_path
      output = convert(output.to_s, document)
      document.content = output

      if document.place_in_layout?
        Bridgetown.logger.debug "Rendering Layout:", document.relative_path
        output = place_in_layouts(output, payload, liquid_context)
      end

      output
    end

    def execute_inline_ruby!
      return unless site.config.should_execute_inline_ruby?

      Bridgetown::Utils::RubyExec.search_data_for_ruby_code(document, self)
    end

    def provide_liquid_context
      {
        registers: {
          site: site,
          page: payload["page"],
          cached_partials: self.class.cached_partials,
        },
        strict_filters: liquid_options["strict_filters"],
        strict_variables: liquid_options["strict_variables"],
      }
    end

    # rubocop: enable Metrics/AbcSize

    # Render the given content with the payload and context
    #
    # content -
    # payload -
    # context    -
    # path    - (optional) the path to the file, for use in ex
    #
    # Returns String the content, rendered by Liquid.
    def render_liquid(content, payload, liquid_context, path = nil)
      template = site.liquid_renderer.file(path).parse(content)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(payload, liquid_context)
    # rubocop: disable Lint/RescueException
    rescue Exception => e
      Bridgetown.logger.error "Liquid Exception:",
                              LiquidRenderer.format_error(e, path || document.relative_path)
      raise e
    end
    # rubocop: enable Lint/RescueException

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
                                "converting '#{document.relative_path}':"
        Bridgetown.logger.error("", e.to_s)
        raise e
      end
    end

    # Checks if the layout specified in the document actually exists
    #
    # layout - the layout to check
    #
    # Returns Boolean true if the layout is invalid, false if otherwise
    def invalid_layout?(layout)
      !document.data["layout"].nil? && layout.nil? && !(document.is_a? Bridgetown::Excerpt)
    end

    # Render layouts and place document content inside.
    #
    # Returns String rendered content
    def place_in_layouts(content, payload, liquid_context)
      output = content.dup
      layout = layouts[document.data["layout"].to_s]
      validate_layout(layout)

      used = Set.new([layout])

      # Reset the payload layout data to ensure it starts fresh for each page.
      payload["layout"] = nil

      while layout
        output = render_layout(output, layout, liquid_context)
        add_regenerator_dependencies(layout)

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
      return unless invalid_layout?(layout)

      Bridgetown.logger.warn "Build Warning:", "Layout '#{document.data["layout"]}' requested " \
        "in #{document.relative_path} does not exist."
    end

    def converters_for_layout(layout)
      site.converters.select do |converter|
        if converter.method(:matches).arity == 1
          converter.matches(layout.ext)
        else
          converter.matches(layout.ext, layout)
        end
      end.sort
    end

    # Render layout content into document.output
    #
    # Returns String rendered content
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def render_layout(output, layout, liquid_context)
      if layout.render_with_liquid?
        liquid_context = provide_liquid_context if liquid_context.nil?

        payload["content"] = output
        payload["layout"]  = Utils.deep_merge_hashes(layout.data, payload["layout"] || {})

        render_liquid(
          layout.content,
          payload,
          liquid_context,
          layout.path
        )
      else
        layout_converters = converters_for_layout(layout)

        layout_content = layout.content.dup
        layout_converters.reduce(layout_content) do |layout_output, converter|
          next(layout_output) unless converter.method(:convert).arity == 2

          layout.current_document = document
          layout.current_document_output = output
          converter.convert layout_output, layout
        rescue StandardError => e
          Bridgetown.logger.error "Conversion error:",
                                  "#{converter.class} encountered an error while "\
                                  "converting '#{document.relative_path}':"
          Bridgetown.logger.error("", e.to_s)
          raise e
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def add_regenerator_dependencies(layout)
      return unless document.write?

      site.regenerator.add_dependency(
        site.in_source_dir(document.path),
        layout.path
      )
    end

    # Set page content to payload and assign paginator if document has one.
    #
    # Returns nothing
    def assign_pages!
      payload["page"] = document.to_liquid
      payload["paginator"] = document.paginator.to_liquid if document.respond_to?(:paginator)
    end

    # Set related posts to payload if document is a post.
    #
    # Returns nothing
    def assign_current_document!
      payload["site"].current_document = document
    end

    # Set highlighter prefix and suffix
    #
    # Returns nothing
    def assign_highlighter_options!
      payload["highlighter_prefix"] = converters.first.highlighter_prefix
      payload["highlighter_suffix"] = converters.first.highlighter_suffix
    end

    def assign_layout_data!
      layout = layouts[document.data["layout"]]
      payload["layout"] = Utils.deep_merge_hashes(layout.data, payload["layout"] || {}) if layout
    end

    def permalink_ext
      document_permalink = document.permalink
      if document_permalink && !document_permalink.end_with?("/")
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

    def liquid_options
      @liquid_options ||= site.config["liquid"]
    end
  end
end
