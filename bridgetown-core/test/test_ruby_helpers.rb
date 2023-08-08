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
      assert_equal "<a href=\"/publish_test/2008/02/02/published/\">Label</a>", @helpers.link_to("Label", "_posts/2008-02-02-published.markdown")
    end

    should "throw error if post doesn't exist" do
      assert_raises ArgumentError do
        @helpers.link_to("Label", "_posts/2008-02-02-publishedMISSING.markdown")
      end
    end

    should "return accept objects which respond to url" do
      assert_equal "<a href=\"/2020/09/10/further-nested/\">Label</a>", @helpers.link_to("Label", @site.collections.posts.resources.first)
    end

    should "pass through relative/absolute URLs" do
      assert_equal "<a href=\"/foo/bar\">Label</a>", @helpers.link_to("Label", "/foo/bar")
      assert_equal "<a href=\"https://apple.com\">Label</a>", @helpers.link_to("Label", "https://apple.com")
    end

    should "accept additional attributes" do
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-test=\"abc123\">Label</a>", @helpers.link_to("Label", "/foo/bar", class: "classes", data_test: "abc123")
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-test=\"abc123\">Label</a>", @helpers.link_to("/foo/bar", class: "classes", data_test: "abc123") { "Label" }
    end

    should "accept hash attributes" do
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-controller=\"test\" data-action=\"test#test\">Label</a>", @helpers.link_to("Label", "/foo/bar", class: "classes", data: { controller: "test", action: "test#test" })
    end

    should "accept anchors" do
      assert_equal "<a href=\"#foo\">Label</a>", @helpers.link_to("Label", "#foo")
    end

    should "accept email links" do
      assert_equal "<a href=\"mailto:a@example.org\">Label</a>", @helpers.link_to("Label", "mailto:a@example.org")
    end

    should "accept telephone links" do
      assert_equal "<a href=\"tel:01234\">Label</a>", @helpers.link_to("Label", "tel:01234")
    end

    should "accept block syntax" do
      assert_equal "<a href=\"/foo/bar\">Label</a>", @helpers.link_to("/foo/bar") { "Label" }
    end

    should "raise if only one argument was given" do
      assert_raises ArgumentError do
        @helpers.link_to("Label")
      end
    end
  end

  context "attributes_from_options" do
    should "return an attribute string from a hash" do
      assert_equal "class=\"classes\" data-test=\"abc123\"", @helpers.attributes_from_options(class: "classes", data_test: "abc123")
    end

    should "handle nested hashes" do
      assert_equal "class=\"classes\" data-controller=\"test\" data-action=\"test#test\" data-test-target=\"test_value\" data-test-index-value=\"1\"", @helpers.attributes_from_options(class: "classes", data: { controller: "test", action: "test#test", test: { target: "test_value", index_value: "1" } })
    end
  end

  context "class_map" do
    should "provide a classes string" do
      yes_var = "yes"
      assert_includes "<p class=\"#{@helpers.class_map blank: !"".empty?, truthy: true, "more-truthy" => yes_var == "yes", falsy: nil, "more-falsy" => "no" == "yes"}\">classes!</p>", "<p class=\"truthy more-truthy\">"
    end
  end
end
