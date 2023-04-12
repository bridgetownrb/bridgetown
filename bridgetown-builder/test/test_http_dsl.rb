# frozen_string_literal: true

require "helper"
require "logger"

class HTTPBuilder < Builder
  attr_reader :stubs

  def build
    @stubs = Faraday::Adapter::Test::Stubs.new
  end

  # Inject our test stubs into the default connection
  def connection(headers: {}, parse_json: true)
    super do |faraday|
      faraday.adapter(:test, stubs)
    end
  end

  def test_get
    get "/test.json" do |data|
      @site.config[:received_data] = data
    end
  end

  def test_bad_json
    get "/test_bad.json" do |data|
      @site.config[:received_data] = data
    end
  end

  def test_headers(headers)
    get "/test_headers.json", headers: headers do |data|
      @site.config[:received_headers] = data
    end
  end

  def test_not_parsing_json
    get "/test_not_parsing.html", parse_json: false do |data|
      @site.config[:received_data] = data
    end
  end

  def test_parameters(**params)
    get "/test_parameters.json", **params do |data|
      @site.config[:received_parameters] = data
    end
  end

  def test_redirect
    get "/test_redirect.json" do |data|
      @site.config[:received_data] = data
    end
  end
end

class TestHTTPDSL < BridgetownUnitTest
  context "dsl for http requests" do
    setup do
      @site = Site.new(site_configuration)
      @builder = HTTPBuilder.new("Hooks Test", @site).build_with_callbacks
    end

    should "add data from external API" do
      @builder.stubs.get("/test.json") do |_env|
        [
          200,
          { "Content-Type": "application/json" },
          '{"data": {"was": ["received"]}}',
        ]
      end

      @builder.test_get
      assert_equal "received", @site.config[:received_data]["data"]["was"].first
    end

    should "not add data from bad external API" do
      @builder.stubs.get("/test_bad.json") do |_env|
        [
          200,
          { "Content-Type": "application/json" },
          '{something is very #@$!^& wrong}',
        ]
      end

      error = capture_stdout do
        @builder.test_bad_json
      end

      refute @site.config[:received_data]
      assert_includes error,
                      "Faraday::ParsingError The response from /test_bad.json did not contain valid JSON"
    end

    should "not parse JSON if parse_json is false" do
      @builder.stubs.get("/test_not_parsing.html") do |_env|
        [
          200,
          { "Content-Type": "application/json" },
          '[1, 2, ["three"]]',
        ]
      end

      @builder.test_not_parsing_json

      assert_equal '[1, 2, ["three"]]', @site.config[:received_data]
    end

    should "redirect automatically" do
      @builder.stubs.get("/test.json") do |_env|
        [
          200,
          { "Content-Type": "application/json" },
          '{"data": {"was": ["received"]}}',
        ]
      end
      @builder.stubs.get("/test_redirect.json") do |_env|
        [
          301,
          { Location: "/test.json" },
        ]
      end

      @builder.test_redirect

      assert_equal "received", @site.config[:received_data]["data"]["was"].first
    end

    should "correctly pass headers to the GET request" do
      @builder.stubs.get("/test_headers.json") do |env|
        [
          200,
          { "Content-Type": "application/json" },
          env.request_headers
        ]
      end

      @builder.test_headers({ "X-Test" => "hello, world"})

      assert_equal "hello, world", @site.config[:received_headers]["X-Test"]
    end

    should "allows passing parameters to the GET request" do
      @builder.stubs.get("/test_parameters.json") do |env|
        [
          200,
          { "Content-Type": "application/json" },
          env.params.to_json
        ]
      end

      @builder.test_parameters(hello: "world")

      assert_equal "world", @site.config[:received_parameters][:hello]
    end
  end
end
