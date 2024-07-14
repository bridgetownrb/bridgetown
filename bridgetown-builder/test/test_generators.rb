# frozen_string_literal: true

require "helper"

class GeneratorBuilder < Builder
  priority :low

  def build
    generator do
      site.signals[:site_metadata][:title] = "Test Title"
    end
  end
end

class GeneratorBuilder2 < Builder
  priority :normal

  def build
    generator do
      site.signals[:site_metadata][:title] = "Test Title 2"
    end
  end
end

class TestGenerators < BridgetownUnitTest
  context "creating a generator" do
    should "be loaded on site setup" do
      @builders = [GeneratorBuilder, GeneratorBuilder2].sort
      @site = Site.new(site_configuration)
      @site.signals[:site_metadata] = { title: "Initial Value" }

      funcs = []
      @builders.each_with_index do |builder, index|
        builder.new("Generator Test #{index}", @site).build_with_callbacks.tap do |b|
          funcs += b.functions.to_a
        end
      end

      assert_equal 2, (@site.generators.map(&:class) & funcs.map { _1[:generator] }).length
      @site.generate

      assert_equal "Test Title", @site.metadata[:title]
    end
  end
end
