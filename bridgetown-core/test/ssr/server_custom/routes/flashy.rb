# frozen_string_literal: true

class Routes::Flashy < Bridgetown::Rack::Routes
  route do |r|
    # route: POST /flashy/:name
    r.post "flashy", String do |name|
      flash.info = "Save this value: #{name}"
    end

    r.get "flashy" do
      { saved: flash.info }
    end
  end
end
