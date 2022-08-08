# frozen_string_literal: true

require "helper"

class TestRoutes < BridgetownUnitTest
  include Rack::Test::Methods

  def app
    ENV["RACK_ENV"] = "development"
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__)).first # rubocop:disable Style/ClassVars
  end

  def site
    app.opts[:bridgetown_site]
  end

  context "Roda-powered Bridgetown server" do
    setup do
      Bridgetown::Current.site = nil
    end

    teardown do
      Bridgetown::Current.preloaded_configuration = nil
    end

    should "return the index page" do
      get "/"
      assert last_response.ok?
      assert_equal "<h1>Index</h1>", last_response.body
    end

    should "return JSON for the hello route" do
      get "/hello/world"
      assert last_response.ok?
      assert_equal({ hello: "friend world" }.to_json, last_response.body)
    end

    should "return HTML for the howdy route" do
      get "/howdy?yo=joe&happy=pleased"
      assert_equal "<h1>joe 42</h1>\n\n<p>I am pleasedpleased.</p>\n", last_response.body
    end

    should "return HTML for a route in an arbitrary folder" do
      get "/yello/my-friend"
      assert_equal "<p>So arbitrary!</p>\n", last_response.body
    end
  end
end
