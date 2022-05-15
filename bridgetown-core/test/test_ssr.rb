# frozen_string_literal: true

require "helper"

class TestSSR < BridgetownUnitTest
  include Rack::Test::Methods

  def app
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__)).first # rubocop:disable Style/ClassVars
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
      assert_equal({ hello: "friend world VALUE" }.to_json, last_response.body)
    end

    should "preserve site data between live reloads" do
      app # ensure it's been run
      site = @@ssr_app.opts[:bridgetown_site]
      assert_equal 1, site.data.iterations
      site.reset(soft: true)
      assert_equal 2, site.data.iterations
    end
  end
end
