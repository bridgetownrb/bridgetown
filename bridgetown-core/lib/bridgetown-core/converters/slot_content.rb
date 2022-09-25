# frozen_string_literal: true

module Bridgetown
  module Converters
    class SlotContent < Converter
      priority :lowest

      def matches(ext)
        true unless ["html"].include?(ext)
      end

      def convert(content, convertible)
        document = convertible.is_a?(Layout) ? convertible.current_document : convertible

        string = content
        buff = +""
        until string.empty?
          text, code, string = string.partition(
            %r{<bridgetown-slot-1 name="(.*?)".*?>(.*?)</bridgetown-slot-1>}m
          )

          buff << text

          next unless code.length.positive?

          document.slots << Slot.new(
            name: ::Regexp.last_match(1),
            content: ::Regexp.last_match(2)
          )
        end

        buff
      end
    end
  end
end
