# frozen_string_literal: true

require "helper"

class TestSSR < BridgetownUnitTest
  include Rack::Test::Methods

  def app
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__)).first
  end

  context "Roda-powered Bridgetown server" do
    setup do
      Bridgetown::Current.site = nil
    end

    teardown do
      Bridgetown.sites.clear
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
      assert_equal({ hello: "friend world IVAR" }.to_json, last_response.body)
    end
  end
end
