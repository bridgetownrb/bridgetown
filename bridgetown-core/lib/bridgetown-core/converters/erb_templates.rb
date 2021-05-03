# frozen_string_literal: true

require "tilt/erubi"

module Bridgetown
  class ERBBuffer < String
    def concat_to_s(input)
      concat input.to_s
    end

    alias_method :safe_append=, :concat_to_s
    alias_method :append=, :concat_to_s
    alias_method :safe_expr_append=, :concat_to_s
  end

  class ERBEngine < Erubi::Engine
    private

    def add_code(code)
      @src << code
      @src << ";#{@bufvar};" if code.strip.split(".").first == "end"
      @src << ";" unless code[Erubi::RANGE_LAST] == "\n"
    end

    # pulled from Rails' ActionView
    BLOCK_EXPR = %r!\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z!.freeze

    def add_expression(indicator, code)
      if BLOCK_EXPR.match?(code)
        src << "#{@bufvar}.append= " << code
      else
        super
      end
    end

    # Don't allow == to output escaped strings, as that's the opposite of Rails
    def add_expression_result_escaped(code)
      add_expression_result(code)
    end
  end

  class ERBView < RubyTemplateView
    def h(input)
      Erubi.h(input)
    end

    def partial(partial_name, options = {})
      options.merge!(options[:locals]) if options[:locals]
      options[:content] = yield if block_given?

      partial_segments = partial_name.split("/")
      partial_segments.last.sub!(%r!^!, "_")
      partial_name = partial_segments.join("/")

      Tilt::ErubiTemplate.new(
        site.in_source_dir(site.config[:partials_dir], "#{partial_name}.erb"),
        outvar: "@_erbout",
        bufval: "Bridgetown::ERBBuffer.new",
        engine_class: ERBEngine
      ).render(self, options)
    end

    def markdownify(input = nil, &block)
      content = Bridgetown::Utils.reindent_for_markdown(
        block.nil? ? input.to_s : capture(&block)
      )
      converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
      result = converter.convert(content).strip
      result.respond_to?(:html_safe) ? result.html_safe : result
    end

    def capture(*args, &block)
      return capture_in_view_component(*args, &block) if @in_view_component

      previous_buffer_state = @_erbout
      @_erbout = ERBBuffer.new
      result = yield(*args)
      @_erbout = previous_buffer_state

      result.respond_to?(:html_safe) ? result.html_safe : result
    end
  end

  module Converters
    class ERBTemplates < Converter
      priority :highest
      input :erb

      # Logic to do the ERB content conversion.
      #
      # @param content [String] Content of the file (without front matter).
      # @param convertible [Bridgetown::Page, Bridgetown::Document, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      #
      # @return [String] The converted content.
      def convert(content, convertible)
        return content if convertible.data[:template_engine] != "erb"

        erb_view = Bridgetown::ERBView.new(convertible)

        erb_renderer = Tilt::ErubiTemplate.new(
          convertible.relative_path,
          outvar: "@_erbout",
          bufval: "Bridgetown::ERBBuffer.new",
          engine_class: ERBEngine
        ) { content }

        if convertible.is_a?(Bridgetown::Layout)
          erb_renderer.render(erb_view) do
            convertible.current_document_output
          end
        else
          erb_renderer.render(erb_view)
        end
      end

      def matches(ext, convertible)
        if convertible.data[:template_engine] == "erb" ||
            (convertible.data[:template_engine].nil? &&
              @config[:template_engine] == "erb")
          convertible.data[:template_engine] = "erb"
          return true
        end

        super(ext).tap do |ext_matches|
          convertible.data[:template_engine] = "erb" if ext_matches
        end
      end

      def output_ext(ext)
        ext == ".erb" ? ".html" : ext
      end
    end
  end
end
