# frozen_string_literal: true

require "helper"

class HelpersBuilder < Builder
  def build
    helper "block_based" do |something|
      "Block Based #{something} #{self.class}"
    end

    helper "within_helpers_scope", helpers_scope: true do |something|
      "Within Helpers Scope Based #{something} #{self.class} #{slugify("I Am Groot")} #{view.class} #{site.class}"
    end

    helper "method_based", :method_based
  end

  def method_based(something)
    "Method Based #{something} #{self.class}"
  end
end

class TestHelpers < BridgetownUnitTest
  context "adding helpers" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)
      @builder = HelpersBuilder.new("HelpersBuilder", @site)
      @resource = Bridgetown::Model::Base.build(self, :posts, "im-a-post.md", {
        title: "I'm a post!",
        date: "2019-05-01",
      }).as_resource_in_collection
      @erb_view = Bridgetown::ERBView.new(@resource)
    end

    should "work with blocks" do
      content = "This is the <%= block_based page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      assert_equal "This is the Block Based I'm a post! HelpersBuilder helper", result
    end

    should "allow execution within helpers scope" do
      content = "This is the <%= within_helpers_scope page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      assert_equal "This is the Within Helpers Scope Based I'm a post! " \
        "Bridgetown::RubyTemplateView::Helpers i-am-groot Bridgetown::ERBView " \
        "Bridgetown::Site helper", result
    end

    should "work with methods" do
      content = "This is the <%= method_based page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      assert_equal "This is the Method Based I'm a post! HelpersBuilder helper", result
    end
  end
end
