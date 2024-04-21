# frozen_string_literal: true

module Bridgetown
  module Filters
    module FromLiquid
      extend Liquid::StandardFilters

      def strip_html(...) = FromLiquid.strip_html(...)

      def strip_newlines(...) = FromLiquid.strip_newlines(...)

      def newline_to_br(...) = FromLiquid.newline_to_br(...)

      def truncate(...) = FromLiquid.truncate(...)

      def truncate_words(...) = FromLiquid.truncatewords(...)
    end
  end
end
