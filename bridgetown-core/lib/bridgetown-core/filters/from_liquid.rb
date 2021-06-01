# frozen_string_literal: true

module Bridgetown
  module Filters
    module FromLiquid
      extend Liquid::StandardFilters

      def strip_html(input)
        FromLiquid.strip_html(input)
      end

      def strip_newlines(input)
        FromLiquid.strip_newlines(input)
      end

      def newline_to_br(input)
        FromLiquid.newline_to_br(input)
      end

      # FYI, truncate and truncate words are already provided by ActiveSupport! =)
    end
  end
end
