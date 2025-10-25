# frozen_string_literal: true

require "helper"
require "rack"
require "rack/test"

# FIXME: errors and failures from these tests, but only when running with other
# tests (script/test or script/cibuild); no failures when running just this
# file (script/test test/test_ssr.rb).
#
# Test output:
#   Error:
#   TestFilters::filters::where_exp filter#test_0012_filters by variable values:
#   Liquid::ArgumentError: Liquid error: comparison of Date with Time failed
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/condition.rb:148:in `rescue in interpret_condition'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/condition.rb:145:in `interpret_condition'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/condition.rb:68:in `block in evaluate'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/condition.rb:67:in `loop'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/condition.rb:67:in `evaluate'
#       lib/bridgetown-core/filters.rb:204:in `block (2 levels) in where_exp'
#       lib/bridgetown-core/filters.rb:199:in `select'
#       lib/bridgetown-core/filters.rb:199:in `block in where_exp'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/liquid-5.4.0/lib/liquid/context.rb:134:in `stack'
#       lib/bridgetown-core/filters.rb:198:in `where_exp'
#       test/test_filters.rb:1302:in `block (3 levels) in <class:TestFilters>'
#
#   Error:
#   TestSSR::Roda-powered Bridgetown server#test_0014_allows plugins to work without order dependence with a base path:
#   NoMethodError: undefined method `config' for nil:NilClass
#
#         site.config.base_path = original_base_path
#             ^^^^^^^
#       test/test_ssr.rb:136:in `ensure in block (2 levels) in <class:TestSSR>'
#       test/test_ssr.rb:136:in `block (2 levels) in <class:TestSSR>'
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0012_returns rendered view [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:112]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0009_returns model as rendered resource [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:89]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0002_returns JSON for the hello route [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:39]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0006_supports incoming JSON payloads [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:64]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0003_supports _method override of POST [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:45]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0008_returns rendered resource [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:82]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Error:
#   TestSSR::Roda-powered Bridgetown server#test_0007_supports redirecting with helpers:
#   NoMethodError: undefined method `config' for nil:NilClass
#
#         site.config.url = "http://test.site"
#             ^^^^^^^
#       test/test_ssr.rb:69:in `block (2 levels) in <class:TestSSR>'
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0005_supports indifferent cookies [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:59]
#   Minitest::Assertion: --- expected
#   +++ actual
#   @@ -1 +1,3 @@
#   -"{\"value\":\"Gookie!\"}"
#   +# encoding: ASCII-8BIT
#   +#    valid: true
#   +"{\"value\":null}"
#
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0010_returns rendered component [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:96]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Failure:
#   TestSSR::Roda-powered Bridgetown server#test_0013_allows plugins to work without order dependence [/Users/felipe.vogel/dev/bridgetown/bridgetown-core/test/test_ssr.rb:123]
#   Minitest::Assertion: Expected false to be truthy.
#
#   Error:
#   TestSSR::Roda-powered Bridgetown server#test_0011_returns flash value:
#   JSON::ParserError: unexpected character: '<h1>500' at line 1 column 1
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/json-2.15.1/lib/json/common.rb:358:in `parse'
#       /Users/felipe.vogel/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/json-2.15.1/lib/json/common.rb:358:in `parse'
#       test/test_ssr.rb:106:in `block (2 levels) in <class:TestSSR>'
#
#   Error:
#   TestSSR::Roda-powered Bridgetown server#test_0004_preserves site data between live reloads:
#   NoMethodError: undefined method `data' for nil:NilClass
#
#         assert_equal 1, site.data.iterations
#                             ^^^^^
#       test/test_ssr.rb:50:in `block (2 levels) in <class:TestSSR>'
#
#   867 tests, 2245 assertions, 9 failures, 5 errors, 2 skips
class TestSSR < BridgetownUnitTest
  include Rack::Test::Methods

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
      expect(last_response).must_be :ok?
      expect(last_response.body) == "<h1>Index</h1>"
    end

    it "returns JSON for the hello route" do
      get "/hello/world"
      assert last_response.ok?
      assert_equal({ hello: "friend world VALUE" }.to_json, last_response.body)
    end

    it "supports _method override of POST" do
      post "/hello/methods", _method: "put"
      assert last_response.ok?
      assert_equal({ saved: "methods" }.to_json, last_response.body)
    end

    it "preserves site data between live reloads" do
      assert_equal 1, site.data.iterations
      site.reset(soft: true)
      assert_equal 2, site.data.iterations
    end

    it "supports indifferent cookies" do
      post "/cookies", value: "Gookie!"
      get "/cookies"
      assert last_response.ok?
      assert_equal({ value: "Gookie!" }.to_json, last_response.body)
    end

    it "supports incoming JSON payloads" do
      post "/ooh_json", { tell_me: "what you're chasin'" }
      assert last_response.ok?
      assert_equal({ because_the_night: "will never give you what you want" }.to_json, last_response.body)
    end

    it "supports redirecting with helpers" do
      site.config.url = "http://test.site"
      post "/redirect_me/now"

      refute last_response.ok?

      get last_response["Location"].sub("http://test.site", "")
      assert last_response.ok?
      assert_equal("Redirected!", last_response.body)
    end

    it "returns rendered resource" do
      get "/render_resource"

      assert last_response.ok?
      assert_includes last_response.body, "<p>Hello <strong>world</strong>!</p>"
    end

    it "returns model as rendered resource" do
      get "/render_model"

      assert last_response.ok?
      assert_includes last_response.body, "<p class=\"test\">THIS IS A <em>TEST</em>.</p>"
    end

    it "returns rendered component" do
      get "/render_component/wow"

      assert last_response.ok?
      assert_equal "application/rss+xml", last_response["Content-Type"]
      assert_equal "<rss>WOW true</rss>", last_response.body
    end

    it "returns flash value" do
      post "/flashy/abc12356"

      get "/flashy"

      assert_equal({ "saved" => "Save this value: abc12356" }, JSON.parse(last_response.body))
    end

    it "returns rendered view" do
      get "/render_view/Page_Me"

      assert last_response.ok?
      assert_includes last_response.body, "<title>PAGE_ME | So Awesome</title>"
      assert_includes last_response.body, "<body class=\"page some-extras\">"
      assert_includes last_response.body, "<h1>PAGE_ME</h1>"
      assert_includes last_response.body, "<ul>\n  <li>Port 80</li>\n</ul>"
      assert_includes last_response.body, "<p>Well that was 246!\n  <em>ya think?</em></p>"
    end

    it "allows plugins to work without order dependence" do
      get "/order-independence"

      assert last_response.ok?
      assert_equal({ it: "works" }.to_json, last_response.body)
    end

    it "allows plugins to work without order dependence with a base path" do
      original_base_path = site.config.base_path
      site.config.base_path = "/subpath"

      get "/order-independence"

      assert last_response.ok?
      assert_equal({ it: "works" }.to_json, last_response.body)
    ensure
      site.config.base_path = original_base_path
    end
  end
end
