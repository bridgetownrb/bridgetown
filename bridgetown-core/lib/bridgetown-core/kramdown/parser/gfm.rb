# frozen_string_literal: true

require "kramdown-parser-gfm"

module Kramdown
  module Parser
    class GFM
      MARK_DELIMITER = %r{(==|::)+}
      MARK_MATCH = %r{#{MARK_DELIMITER}(?!\s|=|:).*?[^\s=:]#{MARK_DELIMITER}}m

      # Monkey-patch GFM initializer to add our new mark parser
      alias_method :_old_initialize, :initialize
      def initialize(source, options)
        _old_initialize(source, options)
        @span_parsers << :mark if @options[:mark_highlighting]
      end

      def parse_mark
        line_number = @src.current_line_number

        @src.pos += @src.matched_size
        el = Element.new(:html_element, "mark", {}, category: :span, line: line_number)
        @tree.children << el

        env = save_env
        reset_env(src: Kramdown::Utils::StringScanner.new(@src.matched[2..-3], line_number),
                  text_type: :text)
        parse_spans(el)
        restore_env(env)

        el
      end
      define_parser(:mark, MARK_MATCH)
    end
  end
end
