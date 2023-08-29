# frozen_string_literal: true

module Bridgetown
  module Tags
    class TranslationTag < Liquid::Tag
      include Bridgetown::Filters::TranslationFilters

      def render(_context)
        input, options = @markup.split.map(&:strip)
        options ||= ""

        t(input, options).to_s
      end
    end
  end
end

Liquid::Template.register_tag("t", Bridgetown::Tags::TranslationTag)
