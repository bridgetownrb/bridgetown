# frozen_string_literal: true

require "helper"

class WithConfigBuilder < Builder
  CONFIG_DEFAULTS = {
    value: "test",
  }.freeze

  attr_reader :value

  def build
    @value = config[:value]
  end
end

class TestTagsDSL < BridgetownUnitTest
  context "adding a Liquid tag" do
    setup do
      @site = Site.new(site_configuration)
    end

    should "get the proper config" do
      builder = WithConfigBuilder.new("Config Defaults", @site).build_with_callbacks
      assert_equal "test", builder.value
    end

    should "get the overridden site config" do
      @site.config[:value] = "overridden"
      builder = WithConfigBuilder.new("Overridden Config Defaults", @site).build_with_callbacks
      assert_equal "overridden", builder.value
    end
  end
end
