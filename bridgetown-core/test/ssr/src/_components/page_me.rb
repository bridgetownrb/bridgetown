# frozen_string_literal: true

class PageMe < Bridgetown::Component
  include Bridgetown::Viewable

  def initialize(title:) # rubocop:disable Lint/MissingSuper
    @title = title.upcase

    data.title = @title
  end

  def call(app)
    @port_number = app.request.port

    render_with(app) do
      layout :page
      page_class "some-extras"
    end
  end
end
