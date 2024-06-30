# frozen_string_literal: true

require "helper"

class HooksBuilder < Builder
  def build
    hook :site, :after_reset do
      site.config[:after_reset_hook_ran] = true
    end

    hook :site, :pre_read do
      site.config[:pre_read_hook_ran] = true
    end
  end
end

class SiteBuilder < Builder
end

class SubclassOfSiteBuilder < SiteBuilder
  class << self
    attr_accessor :final_value
  end

  after_build :run_after

  def build
    site.config[:site_builder_subclass_loaded] = true
  end
  
  def run_after
    self.class.final_value = [@initial_value, :goodbye]
  end
end

SubclassOfSiteBuilder.before_build do
  @initial_value = :hello
end

class TestHooks < BridgetownUnitTest
  context "builder hooks" do
    setup do
      @site = Site.new(site_configuration)
      @builder = HooksBuilder.new("Hooks Test", @site).build_with_callbacks
    end

    should "be triggered" do
      @site.reset
      @site.loaders_manager.unload_loaders
      @site.setup
      Bridgetown::Hooks.trigger :site, :pre_read, @site

      assert @site.config[:after_reset_hook_ran]
      assert @site.config[:pre_read_hook_ran]
    end
  end

  context "SiteBuilder" do
    setup do
      @site = Site.new(site_configuration)
    end

    should "be loaded" do
      @site.reset
      @site.loaders_manager.unload_loaders
      @site.setup
      SubclassOfSiteBuilder.final_value = nil
      Bridgetown::Hooks.trigger :site, :pre_read, @site

      assert @site.config[:site_builder_subclass_loaded]
      assert_equal [:hello, :goodbye], SiteBuilder.subclasses.first.final_value
    end
  end
end
