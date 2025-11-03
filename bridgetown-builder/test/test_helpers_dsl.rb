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

  describe "adding helpers" do
    before do
      @site = Site.new(site_configuration)
      @builder = HelpersBuilder.new("HelpersBuilder", @site).build_with_callbacks
      self.class.instance_variable_set(:@name, "TestHelpers") # reset so this works:
      @resource = Bridgetown::Model::Base.build(self, :posts, "im-a-post.md", {
        title: "I'm a post!",
        date: "2019-05-01",
      }).as_resource_in_collection
      @erb_view = Bridgetown::ERBView.new(@resource)
    end

    it "allow execution with provided helpers scope" do
      content = "This is the <%= block_helper page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      expect(result) == "This is the Within Helpers Scope Based I'm a post! " \
                        "HelpersBuilder i-am-groot Bridgetown::ERBView " \
                        "Bridgetown::Site helper"
    end

    it "work with methods" do
      content = "This is the <%= method_based page.data[:title] %> helper"
      tmpl = Tilt::ErubiTemplate.new(
        outvar: "@_erbout"
      ) { content }
      result = tmpl.render(@erb_view)
      expect(result) ==
        "This is the Method Based I'm a post! HelpersBuilder Bridgetown::ERBView helper"
    end
  end
end
