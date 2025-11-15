# frozen_string_literal: true

require "streamlined/renderable"

module Bridgetown
  class RubyView < ERBView
    input :rb

    def render(item = nil, **options, &block) # rubocop:disable Metrics
      return @_erbout if !block && options.empty? && item.nil?

      if item.is_a?(Proc) || (block && item.nil?)
        result = item.is_a?(Proc) ? item.() : yield
        return result if result.is_a?(OutputBuffer)

        @_erbout ||= OutputBuffer.new
        @_erbout << result.to_s.html_safe

        return @_erbout
      end

      if item.respond_to?(:render_in)
        result = item.render_in(self, &block)
        result&.to_s&.html_safe
      else
        partial(item, **options, &block)&.html_safe
      end
    end

    def _render_partial(partial_path, options) # rubocop:todo Metrics
      (@_locals_stack ||= []).push(options)
      (@_buffer_stack ||= []).push(@_erbout)
      @_erbout = OutputBuffer.new

      site.tmp_cache["partial-tmpl:#{partial_path}"] ||= {
        signal: site.config.fast_refresh ? Signalize.signal(1) : nil,
      }
      tmpl = site.tmp_cache["partial-tmpl:#{partial_path}"]
      tmpl.template ||= options.keys.map do |k|
        "#{k}=locals[:#{k}];"
      end.push(File.read(partial_path)).join
      tmpl.signal&.value # subscribe so resources are attached to this partial within effect

      instance_eval(tmpl.template).to_s.tap do
        @_locals_stack.pop
        @_erbout = @_buffer_stack.pop
      end
    end

    def _output_buffer
      @_erbout # might be nil
    end

    def locals
      @_locals_stack&.last || {}
    end
  end

  module Converters
    class RubyTemplates < Converter
      priority :highest
      input :rb
      template_engine :ruby

      # rubocop:disable Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
      def convert(content, convertible)
        rb_view = Bridgetown::RubyView.new(convertible)

        rb_view.instance_eval(
          "def __ruby_template;#{content};end", convertible.path.to_s, line_start(convertible)
        )

        results = if convertible.is_a?(Bridgetown::Layout)
                    rb_view.__ruby_template { convertible.current_document_output.html_safe }
                  else
                    rb_view.__ruby_template
                  end
        (rb_view._output_buffer || results).to_s
      end
      # rubocop:enable Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
    end
  end
end
