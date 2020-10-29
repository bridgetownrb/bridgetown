# frozen_string_literal: true

require_relative "../../../../plugin_content/components/example/override_component"

module Example
  class OverrideComponent
    def render_in(_view_context)
      "Yay, it got #{overridden_text}!"
    end
  end
end
