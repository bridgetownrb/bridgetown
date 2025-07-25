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
    should "return the static index page" do
      get "/"
      assert last_response.ok?
      assert_equal "<h1>Index</h1>", last_response.body
    end

    should "return the dynamic index page if present" do
      index_file = File.expand_path("ssr/src/_routes/test_index.erb", __dir__)
      FileUtils.cp(index_file, index_file.sub("test_index.erb", "index.erb"))
      get "/"
      assert last_response.ok?
      assert_equal "<h1>Dynamic Index</h1>", last_response.body
      FileUtils.remove_file(index_file.sub("test_index.erb", "index.erb"))
    end

    should "return JSON for the hello route" do
      get "/hello/world"
      assert last_response.ok?
      assert_equal({ hello: "friend world" }.to_json, last_response.body)
    end

    should "return HTML for the howdy route" do
      get "/howdy?yo=joe&happy=pleased"
      assert_equal "<h1>joe 42 true</h1>\n\n<p>I am pleasedpleased.</p>\n\n<output>Flashy!</output>\n", last_response.body # rubocop:todo Layout/LineLength
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

    should "return JSON for a base route (no template)" do
      get "/bare_route/4"
      assert_equal({ numbers: [2, 4, 6, 8] }.to_json, last_response.body)
    end

    should "return the proper route within an island" do
      get "/paradise" do
        assert_equal "Living in paradise =)", last_response.body
      end

      get "/paradise/dreamy" do
        assert_equal "Ah, island life… =)", last_response.body
      end
    end
  end
end
