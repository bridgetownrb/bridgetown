# frozen_string_literal: true

require "helper"

class MethodSymbolsBuilder < Builder
  def build
    generator :set_title
    liquid_tag :upcase_tag, as_block: true
    liquid_filter "multiply_by_anything", :multiply_filter
    hook :site, :after_reset, :reset_hook
  end

  def set_title
    site.signals[:site_metadata] = { title: "Test Title in Method Symbols" }
  end

  def upcase_tag(attributes, tag)
    (tag.content + attributes).upcase
  end

  def multiply_filter(input, anything)
    input * anything
  end

  def reset_hook(site)
    site.config[:after_reset_hook_ran] = true
  end
end

class TestMethodSymbols < BridgetownUnitTest
  context "adding tags, filters, generators, and hooks using method symbols" do
    setup do
      @site = Site.new(site_configuration)
      @builder = MethodSymbolsBuilder.new("MethodSymbols", @site).build_with_callbacks
    end

    should "load generator on site generate" do
      @site.reset
      @site.signals[:site_metadata] = { title: "Initial Value in Method Symbols" }
      @site.loaders_manager.unload_loaders
      @site.setup

      assert_equal "Initial Value in Method Symbols", @site.metadata[:title]
      @site.generate

      assert_equal "Test Title in Method Symbols", @site.metadata[:title]
    end

    should "work with tags" do
      content = "This is the {% upcase_tag yay %}upcase{% endupcase_tag %} tag"
      result = Liquid::Template.parse(content).render
      assert_equal "This is the UPCASEYAY tag", result
    end

    should "output the filter result" do
      content = "5 times 10 equals {{ 5 | multiply_by_anything:10 }}"
      result = Liquid::Template.parse(content).render
      assert_equal "5 times 10 equals 50", result
    end

    should "trigger hook" do
      @site.reset
      assert @site.config[:after_reset_hook_ran]
    end
  end
end
