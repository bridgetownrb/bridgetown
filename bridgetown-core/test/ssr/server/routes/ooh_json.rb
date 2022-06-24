# frozen_string_literal: true

class Routes::OohJson < Bridgetown::Rack::Routes
  route do |r|
    # route: POST /cookies
    r.post "ooh_json" do
      next { keep_on: "running" } unless params[:tell_me] == "what you're chasin'"

      { because_the_night: "will never give you what you want" }
    end
  end
end
