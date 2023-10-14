# frozen_string_literal: true

module Bridgetown
  module HTMLinRuby
    include Serbea::Pipeline::Helper
    include ERBCapture

    module HTMLProc
      include Serbea::Pipeline::Helper
      attr_accessor :pipe_input

      def to_s
        return pipe(pipe_input, &self).to_s if pipe_input

        self.().to_s
      end
    end

    def text(input = nil, callback = nil)
      if input && callback
        Erubi.h(pipe(input, &callback))
      else
        Erubi.h(input.())
      end
    end

    def html(input = nil, callback = nil)
      (callback || input).singleton_class.include HTMLProc
      callback.pipe_input = input unless callback.nil?

      callback || input
    end

    def html_map(input, callback)
      input.map(&callback).join
    end
  end

  class PureRubyView < ERBView
    include HTMLinRuby

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

    def _render_partial(partial_name, options)
      partial_path = _partial_path(partial_name, "rb")
      return super unless File.exist?(partial_path)

      (@_locals_stack ||= []).push(options)
      (@_buffer_stack ||= []).push(@_erbout)
      @_erbout = OutputBuffer.new

      tmpl = site.tmp_cache["partial-tmpl:#{partial_path}"] ||=
        options.keys.map do |k|
          "#{k}=locals[:#{k}];"
        end.push(File.read(partial_path)).join

      instance_eval(tmpl).to_s.tap do
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

      def convert(content, convertible)
        rb_view = Bridgetown::PureRubyView.new(convertible)
        results = rb_view.instance_eval(
          content, convertible.path.to_s, line_start(convertible)
        )
        rb_view._output_buffer || results.to_s
      end
    end
  end
end
