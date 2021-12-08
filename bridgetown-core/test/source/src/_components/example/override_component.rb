# frozen_string_literal: true

load File.expand_path("../../../../plugin_content/components/example/override_component.rb", __dir__)

module Example
  class OverrideComponent
    def render_in(_view_context)
      "Yay, it got #{overridden_text}!"
    end
  end
end
