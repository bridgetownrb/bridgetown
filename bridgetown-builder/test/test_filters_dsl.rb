# frozen_string_literal: true

require "helper"

class FiltersBuilder < Builder
  def build
    liquid_filter :multiply_by_2 do |input|
      input * 2
    end

    liquid_filter "multiply_by_anything" do |input, anything|
      input * anything
    end

    liquid_filter "multiply_and_optionally_add" do |input, multiply_by, add_by = nil|
      value = input * multiply_by
      add_by ? value + add_by : value
    end

    liquid_filter "site_config" do |input|
      raise "OOPS!" if filters_context.registers[:site] && filters_context.registers[:site] != site

      input.to_s + " #{site.root_dir}"
    end

    liquid_filter "within_filters_scope" do |something|
      sl = filters.slugify(something)
      "Within Filters Scope: #{filters.site_config(sl)} #{filters.reading_time("text")}"
    end
  end
end

class TestFilterDSL < BridgetownUnitTest
  context "adding a Liquid filter" do
    setup do
      @site = Site.new(site_configuration)
      @builder = FiltersBuilder.new("FiltersDSL", @site).build_with_callbacks
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

    should "support optional arguments" do
      content = "5 times 10 equals {{ 5 | multiply_and_optionally_add:10 }}"
      result = Liquid::Template.parse(content).render
      assert_equal "5 times 10 equals 50", result

      content = "5 times 10 plus 3 equals {{ 5 | multiply_and_optionally_add:10, 3 }}"
      result = Liquid::Template.parse(content).render
      assert_equal "5 times 10 plus 3 equals 53", result
    end

    should "allow access to local builder scope" do
      content = "root_dir: {{ 'is' | site_config }}"
      result = Liquid::Template.parse(content).render
      assert_equal "root_dir: is #{@site.root_dir}", result
    end

    should "allow access to filters scope" do
      content = "Scope? {{ 'howdy howdy' | within_filters_scope }}"
      result = Liquid::Template.parse(content).render({}, registers: { site: @site })
      assert_equal "Scope? Within Filters Scope: howdy-howdy #{@site.root_dir} 1", result
    end
  end
end
