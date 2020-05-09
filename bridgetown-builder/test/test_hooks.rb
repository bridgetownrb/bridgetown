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

class TestHooks < BridgetownUnitTest
  context "builder hooks" do
    setup do
      @site = Site.new(site_configuration)
      @builder = HooksBuilder.new("Hooks Test", @site)
    end

    should "be triggered" do
      @site.reset
      @site.setup
      Bridgetown::Hooks.trigger :site, :pre_read

      assert @site.config[:after_reset_hook_ran]
      assert @site.config[:pre_read_hook_ran]
    end
  end
end
