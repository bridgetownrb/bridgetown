# frozen_string_literal: true

require "helper"
require "rack"
require "rack/test"

class TestSSR < BridgetownUnitTest
  include Rack::Test::Methods

  def setup
    # The test suite is more stable when this is run first separately
    skip("Tested in a separate pass.") if ENV["BYPASS_TEST_IN_FULL_SUITE"]
  end

  def app
    @@ssr_app ||= begin # rubocop:disable Style/ClassVars
      ENV["RODA_SECRET_KEY"] = SecureRandom.hex(64)
      Rack::Builder.parse_file(File.expand_path("ssr/config.ru", __dir__))
    end
  end

  def site
    app.opts[:bridgetown_site]
  end

  describe "Roda-powered Bridgetown server" do
    before do
      Bridgetown::Current.site = nil
    end

    after do
      Bridgetown::Current.preloaded_configuration = nil
    end

    it "returns the index page" do
      get "/"
      expect(last_response).is? :ok?
      expect(last_response.body) == "<h1>Index</h1>"
    end

    it "returns JSON for the hello route" do
      get "/hello/world"
      expect(last_response).is? :ok?
      expect(last_response.body) == { hello: "friend world VALUE" }.to_json
    end

    it "supports _method override of POST" do
      post "/hello/methods", _method: "put"
      expect(last_response).is? :ok?
      expect(last_response.body) == { saved: "methods" }.to_json
    end

    it "preserves site data between live reloads" do
      expect(site.data.iterations) == 1
      site.reset(soft: true)
      expect(site.data.iterations) == 2
    end

    it "supports indifferent cookies" do
      post "/cookies", value: "Gookie!"
      get "/cookies"
      expect(last_response).is? :ok?
      expect(last_response.body) == { value: "Gookie!" }.to_json
    end

    it "supports incoming JSON payloads" do
      post "/ooh_json", { tell_me: "what you're chasin'" }
      expect(last_response).is? :ok?
      expect(last_response.body) == { because_the_night: "will never give you what you want" }.to_json
    end

    it "supports redirecting with helpers" do
      site.config.url = "http://test.site"
      post "/redirect_me/now"

      expect(last_response).isnt? :ok?

      get last_response["Location"].sub("http://test.site", "")
      expect(last_response).is? :ok?
      expect(last_response.body) == "Redirected!"
    end

    it "returns rendered resource" do
      get "/render_resource"

      expect(last_response).is? :ok?
      expect(last_response.body) << "<p>Hello <strong>world</strong>!</p>"
    end

    it "returns model as rendered resource" do
      get "/render_model"

      expect(last_response).is? :ok?
      expect(last_response.body) << "<p class=\"test\">THIS IS A <em>TEST</em>.</p>"
    end

    it "returns rendered component" do
      get "/render_component/wow"

      expect(last_response).is? :ok?
      expect(last_response["Content-Type"]) == "application/rss+xml"
      expect(last_response.body) == "<rss>WOW true</rss>"
    end

    it "returns flash value" do
      post "/flashy/abc12356"

      get "/flashy"

      expect(last_response).is? :ok?
      expect(last_response.body) == { "saved" => "Save this value: abc12356" }.to_json
    end

    it "returns rendered view" do
      get "/render_view/Page_Me"

      expect(last_response).is? :ok?
      expect(last_response.body)
        .include?("<title>PAGE_ME | So Awesome</title>")
        .include?("<body class=\"page some-extras\">")
        .include?("<h1>PAGE_ME</h1>")
        .include?("<ul>\n  <li>Port 80</li>\n</ul>")
        .include?("<p>Well that was 246!\n  <em>ya think?</em></p>")
    end

    it "allows plugins to work without order dependence" do
      get "/order-independence"

      expect(last_response).is? :ok?
      expect(last_response.body) == { it: "works" }.to_json
    end

    it "allows plugins to work without order dependence with a base path" do
      original_base_path = site.config.base_path
      site.config.base_path = "/subpath"

      get "/order-independence"

      expect(last_response).is? :ok?
      expect(last_response.body) == { it: "works" }.to_json
    ensure
      site.config.base_path = original_base_path
    end
  end
end
