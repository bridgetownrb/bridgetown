# frozen_string_literal: true

require "helper"

class TestRubyHelpers < BridgetownUnitTest
  def setup
    reset_i18n_config
    @site = fixture_site
    @site.read
    @helpers = Bridgetown::RubyTemplateView::Helpers.new(
      Bridgetown::ERBView.new(
        @site.collections.pages.resources.find { |p| p.basename_without_ext == "about" }
      ),
      @site
    )
  end

  describe "link_to" do
    it "returns post's relative URL" do
      assert_equal "<a href=\"/publish_test/2008/02/02/published/\">Label</a>", @helpers.link_to("Label", "_posts/2008-02-02-published.markdown")
    end

    it "throws error if post doesn't exist" do
      assert_raises ArgumentError do
        @helpers.link_to("Label", "_posts/2008-02-02-publishedMISSING.markdown")
      end
    end

    it "returns accept objects which respond to url" do
      assert_equal "<a href=\"/2023/06/30/ruby-front-matter/\">Label</a>", @helpers.link_to("Label", @site.collections.posts.resources.first)
    end

    it "passes through relative/absolute URLs" do
      assert_equal "<a href=\"/foo/bar\">Label</a>", @helpers.link_to("Label", "/foo/bar")
      assert_equal "<a href=\"https://apple.com\">Label</a>", @helpers.link_to("Label", "https://apple.com")
    end

    it "accepts additional attributes" do
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-test=\"abc123\">Label</a>", @helpers.link_to("Label", "/foo/bar", class: "classes", data_test: "abc123")
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-test=\"abc123\">Label</a>", @helpers.link_to("/foo/bar", class: "classes", data_test: "abc123") { "Label" }
    end

    it "accepts hash attributes" do
      assert_equal "<a href=\"/foo/bar\" class=\"classes\" data-controller=\"test\" data-action=\"test#test\">Label</a>", @helpers.link_to("Label", "/foo/bar", class: "classes", data: { controller: "test", action: "test#test" })
    end

    it "accepts anchors" do
      assert_equal "<a href=\"#foo\">Label</a>", @helpers.link_to("Label", "#foo")
    end

    it "accepts email links" do
      assert_equal "<a href=\"mailto:a@example.org\">Label</a>", @helpers.link_to("Label", "mailto:a@example.org")
    end

    it "accepts telephone links" do
      assert_equal "<a href=\"tel:01234\">Label</a>", @helpers.link_to("Label", "tel:01234")
    end

    it "accepts block syntax" do
      assert_equal "<a href=\"/foo/bar\">Label</a>", @helpers.link_to("/foo/bar") { "Label" }
    end

    it "raises if only one argument was given" do
      assert_raises ArgumentError do
        @helpers.link_to("Label")
      end
    end
  end

  describe "html_attributes" do
    it "returns an attribute string from a hash" do
      assert_equal "class=\"classes\" data-test=\"abc123\"", @helpers.html_attributes(class: "classes", data_test: "abc123")
    end

    it "handles nested hashes" do
      assert_equal "class=\"classes\" data-controller=\"test\" data-action=\"test#test\" data-test-target=\"test_value\" data-test-index-value=\"1\"", @helpers.html_attributes(class: "classes", data: { controller: "test", action: "test#test", test: { target: "test_value", index_value: "1" } })
    end
  end

  describe "class_map" do
    it "provides a classes string" do
      yes_var = "yes"
      assert_includes "<p class=\"#{@helpers.class_map blank: !"".empty?, truthy: true, "more-truthy" => yes_var == "yes", falsy: nil, "more-falsy" => "no" == "yes"}\">classes!</p>", "<p class=\"truthy more-truthy\">"
    end
  end

  describe "translate" do
    it "returns translation when given a string" do
      assert_equal "foo", @helpers.translate("about.foo")
    end

    it "returns translations when given an array" do
      assert_equal %w[foo bar], @helpers.translate(%w[about.foo about.bar])
    end

    it "returns html safe string when key ends with _html" do
      assert @helpers.translate("about.foo_html").html_safe?
    end

    it "returns escaped interpolated values within html safe translation" do
      assert_equal "<button>Click &lt;span&gt;Me&lt;/span&gt;</button>",
                   @helpers.translate("about.dangerous_html", me: "<span>Me</span>")
    end

    it "does not return html safe string when key does not end with _html" do
      refute @helpers.translate("about.foo").html_safe?
    end

    it "returns relative translation when key starts with period" do
      assert_equal "foo", @helpers.translate(".foo")
    end

    it "returns relative translation when key starts with period and view is in a folder" do
      helpers = Bridgetown::RubyTemplateView::Helpers.new(
        Bridgetown::ERBView.new(
          @site.collections.pages.resources.find { |p| p.basename_without_ext == "bar" }
        ),
        @site
      )
      assert_equal "foo", helpers.translate(".foo")
    end

    it "returns relative translation when key starts with period and view has .multi ext" do
      helpers = Bridgetown::RubyTemplateView::Helpers.new(
        Bridgetown::ERBView.new(
          @site.collections.pages.resources.find { |p| p.basename_without_ext == "coc.multi" }
        ),
        @site
      )
      assert_equal "foo", helpers.translate(".foo")
    end

    it "returns relative translation when key starts with period and view has underscores in name" do
      helpers = Bridgetown::RubyTemplateView::Helpers.new(
        Bridgetown::ERBView.new(
          @site.collections.pages.resources.find { |p| p.basename_without_ext == "page_using_erb" }
        ),
        @site
      )
      assert_equal "foo", helpers.translate(".foo")
    end

    it "returns relative translation when key starts with period and view path starts with an underscore" do
      @site = fixture_site("collections" => { "tutorials" => { "output" => true } })
      @site.process
      helpers = Bridgetown::RubyTemplateView::Helpers.new(
        Bridgetown::ERBView.new(
          @site.collections.tutorials.resources.find { |p| p.basename_without_ext == "getting-started" }
        ),
        @site
      )
      assert_equal "foo", helpers.translate(".foo")
    end

    it "returns translation missing if key doesn't exist" do
      assert_equal "Translation missing: en.about.not_here", @helpers.translate(".not_here")
    end

    it "has alias method t" do
      assert_equal @helpers.method(:translate), @helpers.method(:t)
    end
  end

  describe "localize" do
    it "returns same output as I18n.localize" do
      time = Time.now
      assert_equal I18n.localize(time), @helpers.localize(time)
    end

    it "has alias method l" do
      assert_equal @helpers.method(:localize), @helpers.method(:l)
    end
  end
end
