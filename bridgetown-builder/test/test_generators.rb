# frozen_string_literal: true

require "helper"

class GeneratorBuilder < Builder
  priority :low

  def build
    generator do
      site.data[:site_metadata][:title] = "Test Title"
    end
  end
end

class GeneratorBuilder2 < Builder
  priority :normal

  def build
    generator do
      site.data[:site_metadata][:title] = "Test Title 2"
    end
  end
end

class TestGenerators < BridgetownUnitTest
  context "creating a generator" do
    setup do
      @site = Site.new(site_configuration)
      @builders = [GeneratorBuilder, GeneratorBuilder2].sort
      @builders.each_with_index do |builder, index|
        builder.new("Generator Test #{index}", @site).build_with_callbacks
      end
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
