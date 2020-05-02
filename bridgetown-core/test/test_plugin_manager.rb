# frozen_string_literal: true

require "helper"

class TestPluginManager < BridgetownUnitTest
  def with_no_gemfile
    FileUtils.mv "../Gemfile", "../Gemfile.old"
    yield
  ensure
    FileUtils.mv "../Gemfile.old", "../Gemfile"
  end

  context "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil`" do
    setup do
      FileUtils.cp "../Gemfile", "."
    end

    teardown do
      FileUtils.rm "Gemfile"
    end

    should "require from bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", nil) do
        assert Bridgetown::PluginManager.require_from_bundler,
               "require_from_bundler should return true."
        assert ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"], "Gemfile plugins were not required."
      end
    end
  end

  context "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `true`" do
    setup do
      FileUtils.cp "../Gemfile", "."
    end

    teardown do
      FileUtils.rm "Gemfile"
    end

    should "not require from bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", "true") do
        refute Bridgetown::PluginManager.require_from_bundler,
               "Gemfile plugins were required but shouldn't have been"
        assert ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"]
      end
    end
  end

  context "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil` and no Gemfile present" do
    should "not require from bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", nil) do
        with_no_gemfile do
          refute Bridgetown::PluginManager.require_from_bundler,
                 "Gemfile plugins were required but shouldn't have been"
          assert_nil ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"]
        end
      end
    end
  end

  context "site containing plugins" do
    should "require plugin files" do
      site = double(config: { "plugins_dir" => "_plugins" },
                    in_source_dir: "/tmp/")
      plugin_manager = PluginManager.new(site)

      expect(Bridgetown::External).to receive(:require_with_graceful_fail)
      plugin_manager.require_plugin_files
    end
  end

  context "plugins_dir is set to the default" do
    should "call site's in_source_dir" do
      site = double(
        config: {
          "plugins_dir" => Bridgetown::Configuration::DEFAULTS["plugins_dir"],
        },
        in_source_dir: "/tmp/"
      )
      plugin_manager = PluginManager.new(site)

      expect(site).to receive(:in_root_dir).with("plugins")
      plugin_manager.plugins_path
    end
  end

  context "plugins_dir is set to a different dir" do
    should "expand plugin path" do
      site = double(config: { "plugins_dir" => "some_other_plugins_path" })
      plugin_manager = PluginManager.new(site)

      expect(File).to receive(:expand_path).with("some_other_plugins_path")
      plugin_manager.plugins_path
    end
  end

  context "third-party plugins can supply content" do
    setup do
      fixture_site.process
    end

    context "extra component file" do
      setup do
        @result = File.read(dest_dir("plugin_content", "components.html"))
      end

      should "correctly render plugin component" do
        assert_match ":This plugin content should come through:", @result
      end

      should "allow overrides of plugin component" do
        assert_match ":Yay, it got overridden!:", @result
      end
    end

    context "extra page and static file" do
      setup do
        @result = File.read(dest_dir("page_from_a_plugin.html"))
        @static_result = File.read(dest_dir("assets", "static.txt"))
      end

      should "read plugin page" do
        assert_match "I am a page from a plugin!", @result
        assert_match ":This layout content should come through:", @result
      end

      should "read static file" do
        assert_match "Static file from a plugin!", @static_result
      end
    end

    context "extra layout file" do
      setup do
        @result = File.read(dest_dir("plugin_content", "layouts.html"))
        @override_result = File.read(dest_dir("plugin_content", "layouts_override.html"))
      end

      should "correctly render plugin layout" do
        assert_match ":This layout content should come through:", @result
      end

      should "correctly render overridden layout" do
        assert_match ":This overriden layout SHOULD come through:", @override_result
        assert_match "The layout should have been overridden", @override_result
      end
    end
  end
end
