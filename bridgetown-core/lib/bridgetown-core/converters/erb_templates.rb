# frozen_string_literal: true

require "tilt/erubi"

module Bridgetown
  class OutputBuffer
    def initialize(buffer = "")
      @buffer = String.new(buffer)
      @buffer.encode!
    end

    def initialize_copy(other)
      @buffer = other.to_str
    end

    delegate(
      :blank?,
      :empty?,
      :encode,
      :encode!,
      :encoding,
      :force_encoding,
      :length,
      :lines,
      :reverse,
      :strip,
      :valid_encoding?,
      to: :@buffer
    )

    def <<(value)
      return self if value.nil?

      value = value.to_s
      value = CGI.escapeHTML(value) unless value.html_safe?

      @buffer << value

      self
    end
    alias_method :append=, :<<

    def ==(other)
      other.instance_of?(OutputBuffer) &&
        @buffer == other.to_str
    end

    def html_safe?
      true
    end

    def safe_concat(value)
      @buffer << value
      self
    end
    alias_method :safe_append=, :safe_concat

    def safe_expr_append=(val)
      return self if val.nil? # rubocop:disable Lint/ReturnInVoidContext

      safe_concat val.to_s
    end

    def to_s
      @buffer.html_safe
    end

    def to_str
      @buffer.dup
    end
  end

  class ERBEngine < Erubi::Engine
    private

    def add_code(code)
      @src << code
      @src << ";#{@bufvar};" if code.strip.split(".").first == "end"
      @src << ";" unless code[Erubi::RANGE_LAST] == "\n"
    end

    def add_text(text)
      return if text.empty?

      src << bufvar << ".safe_append='"
      src << text.gsub(%r{['\\]}, '\\\\\&')
      src << "'.freeze;"
    end

    # pulled from Rails' ActionView
    BLOCK_EXPR = %r!\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z!.freeze

    def add_expression(indicator, code)
      src << bufvar << if (indicator == "==") || @escape
                         ".safe_expr_append="
                       else
                         ".append="
                       end

      if BLOCK_EXPR.match?(code)
        src << " " << code
      else
        src << "(" << code << ");"
      end
    end
  end

  module ERBCapture
    def capture(*args)
      previous_buffer_state = @_erbout
      @_erbout = OutputBuffer.new
      result = yield(*args)
      result = @_erbout.presence || result
      @_erbout = previous_buffer_state

      result.is_a?(String) ? ERB::Util.h(result) : result
    end
  end

  class ERBView < RubyTemplateView
    include ERBCapture

    def h(input)
      Erubi.h(input)
    end

    def partial(partial_name = nil, **options, &block)
      partial_name = options[:template] if partial_name.nil? && options[:template]
      options.merge!(options[:locals]) if options[:locals]
      options[:content] = capture(&block) if block

      _render_partial partial_name, options
    end

    def _render_partial(partial_name, options)
      partial_path = _partial_path(partial_name, "erb")
      tmpl = site.tmp_cache["partial-tmpl:#{partial_path}"] ||= Tilt::ErubiTemplate.new(
        partial_path,
        outvar: "@_erbout",
        bufval: "Bridgetown::OutputBuffer.new",
        engine_class: ERBEngine
      )
      tmpl.render(self, options)
    end
  end

  module Converters
    class ERBTemplates < Converter
      priority :highest
      input :erb

      # Logic to do the ERB content conversion.
      #
      # @param content [String] Content of the file (without front matter).
      # @param convertible [
      #   Bridgetown::GeneratedPage, Bridgetown::Resource::Base, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      #
      # @return [String] The converted content.
      def convert(content, convertible)
        return content if convertible.data[:template_engine].to_s != "erb"

        erb_view = Bridgetown::ERBView.new(convertible)

        erb_renderer = Tilt::ErubiTemplate.new(
          convertible.path,
          line_start(convertible),
          outvar: "@_erbout",
          bufval: "Bridgetown::OutputBuffer.new",
          engine_class: ERBEngine
        ) { content }

        if convertible.is_a?(Bridgetown::Layout)
          erb_renderer.render(erb_view) do
            convertible.current_document_output.html_safe
          end
        else
          erb_renderer.render(erb_view)
        end
      end

      # @param ext [String]
      # @param convertible [Bridgetown::Resource::Base, Bridgetown::GeneratedPage]
      def matches(ext, convertible)
        if convertible.data[:template_engine].to_s == "erb" ||
            (convertible.data[:template_engine].nil? &&
             @config[:template_engine].to_s == "erb")
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
