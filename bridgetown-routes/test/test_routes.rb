# frozen_string_literal: true

require "helper"

class TestRoutes < BridgetownUnitTest
  include Rack::Test::Methods

  def app
    ENV["RACK_ENV"] = "development"
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__)) # rubocop:disable Style/ClassVars
  end

  def site
    app.opts[:bridgetown_site]
  end

  context "Roda-powered Bridgetown server" do # rubocop:todo Metrics/BlockLength
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

    should "return HTML for a route localized in english" do
      get "/localized"
      assert_equal "<h1>Localized for en - en</h1>\n", last_response.body
    end

    should "return HTML for a route localized in italian" do
      get "/it/localized"
      assert_equal "<h1>Localized for it - it</h1>\n", last_response.body
    end

    should "return HTML for nested index RESTful route" do
      get "/nested"
      assert_equal "<h1>Nested Index</h1>\n", last_response.body
    end

    should "return HTML for nested item RESTful route" do
      get "/nested/123-abc"
      assert_equal "<h1>Nested Page with Slug: 123-abc</h1>\n", last_response.body
    end
  end
end
