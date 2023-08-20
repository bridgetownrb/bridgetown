# frozen_string_literal: true

module Bridgetown
  module Tags
    class LocalizationTag < Liquid::Tag
      include Bridgetown::Filters::LocalizationFilters

      def render(_context)
        input, format, locale = @markup.split.map(&:strip)
        l(input, format, locale)
      end
    end
  end
end

Liquid::Template.register_tag("l", Bridgetown::Tags::LocalizationTag)
