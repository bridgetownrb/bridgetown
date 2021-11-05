# frozen_string_literal: true

require "helper"

class GeneratorBuilder < Builder
  def build
    generator do
      site.data[:site_metadata][:title] = "Test Title"
    end
  end
end

class TestGenerators < BridgetownUnitTest
  context "creating a generator" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)
      @builder = GeneratorBuilder.new("Generator Test", @site).build_with_callbacks
    end

    should "be loaded on site setup" do
      @site.reset
      @site.data[:site_metadata] = { title: "Initial Value" }
      @site.loaders_manager.unload_loaders
      @site.setup
      @site.generate

      assert_equal "Test Title", @site.metadata[:title]
    end
  end
end
