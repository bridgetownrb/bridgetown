# frozen_string_literal: true

class Routes::Cookies < Bridgetown::Rack::Routes
  route do |r|
    # route: GET /cookies
    r.get "cookies" do
      { value: r.cookies[:test_key] }
    end

    # route: POST /cookies
    r.post "cookies" do
      response.set_cookie :test_key, {
        value: r.params[:value],
        httponly: true,
      }

      { value: r.cookies[:test_key] }
    end
  end
end
