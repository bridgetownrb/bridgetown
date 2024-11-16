# frozen_string_literal: true

module Bridgetown
  module Converters
    # Identity converter. Returns same content as given.
    # For more info on converters see https://bridgetownrb.com/docs/plugins/converters/
    class Identity < Converter
      priority :lowest

      support_slots

      # @return [Boolean] true since it always matches.
      def matches(*)
        true
      end

      # @param ext [String] the extension of the original file
      # @return [String] The output file extension (including the dot)
      def output_ext(ext)
        ext
      end
    end
  end
end
