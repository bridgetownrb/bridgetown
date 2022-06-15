# frozen_string_literal: true

class Routes::Redirecting < Bridgetown::Rack::Routes
  route do |r|
    r.on "redirect_me" do
      # route: GET /redirect_me/to_this
      r.get "to_this" do
        "Redirected!"
      end

      # route: POST /redirect_me/now
      r.post "now" do
        r.redirect absolute_url("/redirect_me/to_this")
      end
    end
  end
end
