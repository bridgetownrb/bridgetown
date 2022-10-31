# frozen_string_literal: true

class Routes::Hello < Bridgetown::Rack::Routes
  priority :lowest

  route do |r|
    saved_value = bridgetown_site.data.save_value

    # route: GET /hello/:name
    r.get "hello", String do |name|
      { hello: "friend #{name} #{saved_value}" }
    end

    r.put "hello", String do |name|
      { saved: name }
    end
  end
end
