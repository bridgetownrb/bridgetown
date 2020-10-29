# frozen_string_literal: true

module Example
  class OverrideComponent
    def render_in(_view_context)
      "If you're seeing this, something went wrong :("
    end

    def overridden_text
      "overridden"
    end
  end
end
