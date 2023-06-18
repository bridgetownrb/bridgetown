# frozen_string_literal: true

module Bridgetown
  module Tags
    class DSDTag < Liquid::Block
      def render(_context)
        template_content = super

        Bridgetown::Utils.dsd_tag(template_content)
      end
    end
  end
end

Liquid::Template.register_tag("dsd", Bridgetown::Tags::DSDTag)
