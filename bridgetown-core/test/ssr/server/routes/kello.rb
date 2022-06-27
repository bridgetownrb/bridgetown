# frozen_string_literal: true

class Routes::Kello < Bridgetown::Rack::Routes
  route do |r|
    bridgetown_site.data.save_value = "VALUE"

    # route: GET /kello/:name
    r.get "kello", String do |name|
      { kello: "kriend #{name}" }
    end
  end
end
