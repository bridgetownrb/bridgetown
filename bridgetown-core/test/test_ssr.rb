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
      expect(last_response).must_be :ok?
      expect(last_response.body) == "<h1>Index</h1>"
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

    should "return rendered resource" do
      get "/render_resource"

      assert last_response.ok?
      assert_includes last_response.body, "<p>Hello <strong>world</strong>!</p>"
    end

    should "return model as rendered resource" do
      get "/render_model"

      assert last_response.ok?
      assert_includes last_response.body, "<p class=\"test\">THIS IS A <em>TEST</em>.</p>"
    end

    should "return rendered component" do
      get "/render_component/wow"

      assert last_response.ok?
      assert_equal "application/rss+xml", last_response["Content-Type"]
      assert_equal "<rss>WOW true</rss>", last_response.body
    end

    should "return rendered view" do
      get "/render_view/Page_Me"

      assert last_response.ok?
      assert_includes last_response.body, "<title>PAGE_ME | So Awesome</title>"
      assert_includes last_response.body, "<body class=\"page some-extras\">"
      assert_includes last_response.body, "<h1>PAGE_ME</h1>"
      assert_includes last_response.body, "<ul>\n  <li>Port 80</li>\n</ul>"
      assert_includes last_response.body, "<p>Well that was 246!\n  <em>ya think?</em></p>"
    end
  end
end
