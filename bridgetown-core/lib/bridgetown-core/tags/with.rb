# frozen_string_literal: true

module Bridgetown
  module Tags
    class WithTag < Liquid::Block
      def render(context)
        region_name = @markup.strip
        context["content_with_region_#{region_name}"] = super
        ""
      end
    end
  end
end

Liquid::Template.register_tag("with", Bridgetown::Tags::WithTag)
