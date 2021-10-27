# frozen_string_literal: true

module Bridgetown
  module Tags
    class LiveReloadJsTag < Liquid::Tag
      def render(context)
        Bridgetown::Utils.live_reload_js(context.registers[:site])
      end
    end
  end
end

Liquid::Template.register_tag("live_reload_dev_js", Bridgetown::Tags::LiveReloadJsTag)
