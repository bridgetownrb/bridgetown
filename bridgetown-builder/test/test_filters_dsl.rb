# frozen_string_literal: true

require "helper"

class FiltersBuilder < Builder
  def build
    liquid_filter "multiply_by_2" do |input|
      input * 2
    end

    liquid_filter "multiply_by_anything" do |input, anything|
      input * anything
    end
  end
end

class TestFilterDSL < BridgetownUnitTest
  context "adding a Liquid filter" do
    setup do
      @site = Site.new(site_configuration)
      @builder = FiltersBuilder.new("FiltersDSL", @site)
    end

    should "output the filter result" do
      content = "2 times 2 equals {{ 2 | multiply_by_2 }}"
      result = Liquid::Template.parse(content).render
      assert_equal "2 times 2 equals 4", result
    end

    should "output the filter result based on argument" do
      content = "5 times 10 equals {{ 5 | multiply_by_anything:10 }}"
      result = Liquid::Template.parse(content).render
      assert_equal "5 times 10 equals 50", result
    end
  end
end
