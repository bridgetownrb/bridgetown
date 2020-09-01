# frozen_string_literal: true

module Bridgetown
  module Tags
    class TranslationTag < Liquid::Tag
      def render(_context)
        key = @markup.strip
        I18n.t(key)
      end
    end
  end
end

Liquid::Template.register_tag("t", Bridgetown::Tags::TranslationTag)
