# frozen_string_literal: true

require "helper"

class TestRubyHelpers < BridgetownUnitTest
  def setup
    @site = fixture_site
    @site.read
    @helpers = Bridgetown::RubyTemplateView::Helpers.new(self, @site)
  end

  context "link_to" do
    should "return post's relative URL" do
      assert_equal "<a href=\"/publish-test/2008/02/02/published.html\">Label</a>", @helpers.link_to("Label", "_posts/2008-02-02-published.markdown")
    end

    should "throw error if post doesn't exist" do
      assert_raises ArgumentError do
        @helpers.link_to("Label", "_posts/2008-02-02-publishedMISSING.markdown")
      end
    end

    should "return accept objects which respond to url" do
      assert_equal "<a href=\"/2020/09/10/further-nested.html\">Label</a>", @helpers.link_to("Label", @site.posts.docs.last)
    end

    should "pass through relative/absolute URLs" do
      assert_equal "<a href=\"/foo/bar\">Label</a>", @helpers.link_to("Label", "/foo/bar")
      assert_equal "<a href=\"https://apple.com\">Label</a>", @helpers.link_to("Label", "https://apple.com")
    end

    should "accept additional attributes" do
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-test=\"abc123\">Label</a>", @helpers.link_to("Label", "/foo/bar", class: "classes", data_test: "abc123")
    end
  end

  context "class_map" do
    should "provide a classes string" do
      yes_var = "yes"
      assert_includes "<p class=\"#{@helpers.class_map blank: !"".empty?, truthy: true, "more-truthy" => yes_var == "yes", falsy: nil, "more-falsy" => "no" == "yes"}\">classes!</p>", "<p class=\"truthy more-truthy\">"
    end
  end
end
