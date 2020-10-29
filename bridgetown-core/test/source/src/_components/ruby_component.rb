# frozen_string_literal: true

class RubyComponent
  def render_in(view_context)
    "Here's the page title! <strong>#{view_context.page.data.title}</strong>"
  end
end
