# frozen_string_literal: true

module Bridgetown
  module Tags
    class LocalizationTag < Liquid::Tag
      def render(_context)
        key = @markup.strip
        I18n.l(key)
      end
    end
  end
end

Liquid::Template.register_tag("l", Bridgetown::Tags::LocalizationTag)
