class Routes::Hello < Bridgetown::Rack::Routes
  priority :lowest

  route do |r|
    @ivar = r.instance_variable_get(:@ivar)

    # route: GET /hello/:name
    r.get "hello", String do |name|
      { hello: "friend #{name} #{@ivar}" }
    end
  end
end
