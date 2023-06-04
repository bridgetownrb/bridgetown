# frozen_string_literal: true

require "helper"

class TestPluginManager < BridgetownUnitTest
  context "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil`" do
    setup do
      FileUtils.cp "../Gemfile", "."
    end

    teardown do
      FileUtils.rm "Gemfile"
    end

    should "setup bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", nil) do
        assert Bridgetown::PluginManager.setup_bundler,
               "setup_bundler should return true."
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

    should "not setup bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", "true") do
        refute Bridgetown::PluginManager.setup_bundler,
               "Gemfile plugins were required but shouldn't have been"
        assert ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"]
      end
    end
  end

  context "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil` and no Gemfile present" do
    should "not setup bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", nil) do
        with_env("BRIDGETOWN_ENV", nil) do
          Bundler::SharedHelpers.stub(:in_bundle?, nil) do
            refute Bridgetown::PluginManager.setup_bundler,
                   "Gemfile plugins were required but shouldn't have been"
            assert_nil ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"]
          end
        end
      end
    end
  end

  context "find yarn dependencies" do
    should "work if the metadata exists and is in the right format" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "yarn-add" => "my-plugin@0.1.0",
      }))
      assert_equal ["my-plugin", "0.1.0"], Bridgetown::PluginManager.find_yarn_dependency(gem_mock)
    end

    should "work if the metadata package starts with an @ symbol" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "yarn-add" => "@my-org/my-plugin@0.1.0",
      }))
      assert_equal ["@my-org/my-plugin", "0.1.0"], Bridgetown::PluginManager.find_yarn_dependency(gem_mock)
    end

    should "not work if the metadata doesn't exist" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new)
      assert_equal nil, Bridgetown::PluginManager.find_yarn_dependency(gem_mock)
    end

    should "not work if the metadata isn't in the right format" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "yarn-add" => "gobbledeegook",
      }))
      assert_equal nil, Bridgetown::PluginManager.find_yarn_dependency(gem_mock)

      gem_mock2 = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "yarn-add" => "gobbledee@gook@",
      }))
      assert_equal nil, Bridgetown::PluginManager.find_yarn_dependency(gem_mock2)
    end
  end

  context "check package.json for dependency information" do
    setup do
      @yarn_dep = ["@my-org/my-plugin", "0.2.0"]
      @package_json = {
        "dependencies" => {
          "@my-org/my-plugin" => "0.1.0",
        },
      }
    end

    should "do nothing if there's no yarn dependency" do
      refute Bridgetown::PluginManager.add_yarn_dependency?(nil, @package_json)
    end

    should "green-light if package_json dependencies is missing" do
      assert Bridgetown::PluginManager.add_yarn_dependency?(@yarn_dep, {})
    end

    should "green-light if package_json dependency is old" do
      assert Bridgetown::PluginManager.add_yarn_dependency?(@yarn_dep, @package_json)
    end

    should "do nothing if package_json dependency is the same" do
      @yarn_dep[1] = "0.1.0"
      refute Bridgetown::PluginManager.add_yarn_dependency?(@yarn_dep, @package_json)
    end

    should "green-light if package_json dependency wasn't included" do
      @package_json["dependencies"].delete("my-plugin")
      assert Bridgetown::PluginManager.add_yarn_dependency?(@yarn_dep, @package_json)
    end
  end

  context "verify yarn package" do
    should "install if entry in package.json is blank" do
      assert Bridgetown::PluginManager.package_requires_updating?(nil, "1.0.0")
    end

    should "install if entry in package.json is outdated" do
      assert Bridgetown::PluginManager.package_requires_updating?("1.0.0", "1.0.2")
    end

    should "not install if entry in package.json is the same" do
      refute Bridgetown::PluginManager.package_requires_updating?("1.0.1", "1.0.1")
    end

    should "not install if entry in package.json a URL or file path" do
      refute Bridgetown::PluginManager.package_requires_updating?("../path", "1.0.1")
      refute Bridgetown::PluginManager.package_requires_updating?("http://domain", "1.0.1")
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
        @result = File.read(dest_dir("plugin_content", "components", "index.html"))
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
        @result = File.read(dest_dir("page_from_a_plugin", "index.html"))
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
        @result = File.read(dest_dir("plugin_content", "layouts", "index.html"))
        @override_result = File.read(dest_dir("plugin_content", "layouts_override", "index.html"))
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
