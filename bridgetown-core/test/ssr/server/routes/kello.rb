class Routes::Kello < Bridgetown::Rack::Routes
  route do |r|
    r.instance_variable_set(:@ivar, "IVAR")

    # route: GET /hello/:name
    r.get "kello", String do |name|
      { kello: "kriend #{name} #{@ivar}" }
    end
  end
end
