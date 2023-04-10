# frozen_string_literal: true

require "helper"
require "rack"
require "rack/test"

class TestSSR < BridgetownUnitTest
  include Rack::Test::Methods

  def app
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__)) # rubocop:disable Style/ClassVars
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
      assert_equal({ hello: "friend world VALUE" }.to_json, last_response.body)
    end

    should "support _method override of POST" do
      post "/hello/methods", _method: "put"
      assert last_response.ok?
      assert_equal({ saved: "methods" }.to_json, last_response.body)
    end

    should "preserve site data between live reloads" do
      assert_equal 1, site.data.iterations
      site.reset(soft: true)
      assert_equal 2, site.data.iterations
    end

    should "support indifferent cookies" do
      post "/cookies", value: "Gookie!"
      get "/cookies"
      assert last_response.ok?
      assert_equal({ value: "Gookie!" }.to_json, last_response.body)
    end

    should "support incoming JSON payloads" do
      post "/ooh_json", { tell_me: "what you're chasin'" }
      assert last_response.ok?
      assert_equal({ because_the_night: "will never give you what you want" }.to_json, last_response.body)
    end

    should "support redirecting with helpers" do
      site.config.url = "http://test.site"
      post "/redirect_me/now"

      refute last_response.ok?

      get last_response["Location"].sub("http://test.site", "")
      assert last_response.ok?
      assert_equal("Redirected!", last_response.body)
    end
  end
end
