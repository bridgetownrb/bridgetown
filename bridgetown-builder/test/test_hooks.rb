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
  def build
    site.config[:site_builder_subclass_loaded] = true
  end
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
      Bridgetown::Hooks.trigger :site, :pre_read, @site

      assert @site.config[:site_builder_subclass_loaded]
    end
  end
end
