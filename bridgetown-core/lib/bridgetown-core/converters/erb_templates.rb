# frozen_string_literal: true

require "tilt/erubi"
require "erubi/capture_block"

module Bridgetown
  class OutputBuffer
    extend Forwardable

    def_delegators :@buffer,
                   :empty?,
                   :encode,
                   :encode!,
                   :encoding,
                   :force_encoding,
                   :length,
                   :lines,
                   :reverse,
                   :strip,
                   :valid_encoding?

    def initialize(buffer = "")
      @buffer = String.new(buffer)
      @buffer.encode!
    end

    def initialize_copy(other)
      @buffer = other.to_str
    end

    # Concatenation for <%= %> expressions, whose output is escaped.
    def <<(value)
      return self if value.nil?

      value = value.to_s
      value = Erubi.h(value) unless value.html_safe?

      @buffer << value

      self
    end
    alias_method :append=, :<<

    # Concatenation for <%== %> expressions, whose output is not escaped.
    #
    # rubocop:disable Naming/BinaryOperatorParameterName
    def |(value)
      return self if value.nil?

      safe_concat(value.to_s)
    end
    # rubocop:enable Naming/BinaryOperatorParameterName

    def ==(other)
      other.instance_of?(OutputBuffer) &&
        @buffer == other.to_str
    end

    def html_safe?
      true
    end

    def html_safe = to_s

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

  class ERBEngine < Erubi::CaptureBlockEngine
    private

    def add_text(text)
      return if text.empty?

      src << bufvar << ".safe_concat'"
      src << text.gsub(%r{['\\]}, '\\\\\&')
      src << "'.freeze;"
    end
  end

  module ERBCapture
    def capture(*args)
      previous_buffer_state = @_erbout
      @_erbout = OutputBuffer.new
      result = yield(*args)
      result = @_erbout.presence || result
      @_erbout = previous_buffer_state
      return result.to_s if result.is_a?(OutputBuffer)

      # TODO: resolve below logic once Active Support patch to `ERB::Util.h` is removed
      result.is_a?(String) ? ERB::Util.h(result) : result
    end
  end

  class ERBView < TemplateView
    input :erb

    def h(input)
      Erubi.h(input)
    end

    def partial(partial_name = nil, **options, &block)
      partial_name = options[:template] if partial_name.nil? && options[:template]
      partial_path = _partial_path(partial_name, self.class.extname_list.first.delete_prefix("."))
      unless File.exist?(partial_path)
        @_call_super_method = true
        return super
      end

      options.merge!(options[:locals]) if options[:locals]
      options[:content] = capture(&block) if block

      if @_call_super_method
        method(:_render_partial).super_method.call partial_path, options
      else
        _render_partial partial_path, options
      end
    end

    def _render_partial(partial_path, options)
      site.tmp_cache["partial-tmpl:#{partial_path}"] ||= {
        signal: site.config.fast_refresh ? Signalize.signal(1) : nil,
      }
      tmpl = site.tmp_cache["partial-tmpl:#{partial_path}"]
      tmpl.template ||= Tilt::ErubiTemplate.new(
        partial_path,
        outvar: "@_erbout",
        bufval: "Bridgetown::OutputBuffer.new",
        engine_class: ERBEngine
      )
      tmpl.signal&.value # subscribe so resources are attached to this partial within effect
      tmpl.template.render(self, options)
    end
  end

  module Converters
    class ERBTemplates < Converter
      priority :highest
      input :erb
      template_engine :erb
      helper_delimiters ["<%=", "%>"]

      # Logic to do the ERB content conversion.
      #
      # @param content [String] Content of the file (without front matter).
      # @param convertible [
      #   Bridgetown::GeneratedPage, Bridgetown::Resource::Base, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      #
      # @return [String] The converted content.
      def convert(content, convertible)
        erb_view = Bridgetown::ERBView.new(convertible)

        erb_renderer =
          convertible.site.tmp_cache["erb-tmpl:#{convertible.path}:#{content.hash}"] ||=
            Tilt::ErubiTemplate.new(
              convertible.path,
              line_start(convertible),
              outvar: "@_erbout",
              bufval: "Bridgetown::OutputBuffer.new",
              engine_class: ERBEngine
            ) do
              content
            end

        if convertible.is_a?(Bridgetown::Layout)
          erb_renderer.render(erb_view) do
            convertible.current_document_output.html_safe
          end
        else
          erb_renderer.render(erb_view)
        end
      end
    end
  end
end
