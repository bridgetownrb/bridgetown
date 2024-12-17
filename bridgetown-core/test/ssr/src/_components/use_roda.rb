# frozen_string_literal: true

class UseRoda < Bridgetown::Component
  include Bridgetown::RodaCallable

  def initialize(title:) # rubocop:disable Lint/MissingSuper
    @title = title.upcase
  end

  def template
    "<rss>#{@title} #{@testing}</rss>" # not real RSS =)
  end

  def call(app)
    app => { request:, response: }
    @testing = request.env["rack.test"]

    response["Content-Type"] = "application/rss+xml"

    render_in(app)
  end
end
