# frozen_string_literal: true

require "helper"

class HelpersBuilder < Builder
  def build
    helper "block_helper" do |something|
      "Within Helpers Scope Based #{something} #{self.class} #{helpers.slugify("I Am Groot")} #{helpers.view.class} #{site.class}"
    end

    helper :method_based
  end

  def method_based(something)
    "Method Based #{something} #{self.class} #{helpers.view.class}"
  end
end

class TestHelpers < BridgetownUnitTest
  attr_reader :site

  context "adding helpers" do
    setup do
      @site = Site.new(site_configuration)
      @builder = HelpersBuilder.new("HelpersBuilder", @site).build_with_callbacks
      @resource = Bridgetown::Model::Base.build(self, :posts, "im-a-post.md", {
        title: "I'm a post!",
        date: "2019-05-01",
      }).as_resource_in_collection
      @erb_view = Bridgetown::ERBView.new(@resource)
    end

    should "allow execution with provided helpers scope" do
      content = "This is the <%= block_helper page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      assert_equal "This is the Within Helpers Scope Based I'm a post! " \
                   "HelpersBuilder i-am-groot Bridgetown::ERBView " \
                   "Bridgetown::Site helper", result
    end

    should "work with methods" do
      content = "This is the <%= method_based page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      assert_equal "This is the Method Based I'm a post! HelpersBuilder Bridgetown::ERBView helper",
                   result
    end
  end
end
