# frozen_string_literal: true

require "helper"

class TestPluginManager < BridgetownUnitTest
  describe "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil`" do
    before do
      FileUtils.cp "../Gemfile", "."
    end

    after do
      FileUtils.rm "Gemfile"
    end

    it "sets up bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", nil) do
        assert Bridgetown::PluginManager.setup_bundler,
               "setup_bundler should return true."
        assert ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"], "Gemfile plugins were not required."
      end
    end
  end

  describe "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `true`" do
    before do
      FileUtils.cp "../Gemfile", "."
    end

    after do
      FileUtils.rm "Gemfile"
    end

    it "does not set up bundler" do
      with_env("BRIDGETOWN_NO_BUNDLER_REQUIRE", "true") do
        refute Bridgetown::PluginManager.setup_bundler,
               "Gemfile plugins were required but shouldn't have been"
        assert ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"]
      end
    end
  end

  describe "BRIDGETOWN_NO_BUNDLER_REQUIRE set to `nil` and no Gemfile present" do
    it "does not set up bundler" do
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

  describe "find npm dependencies" do
    it "works if the metadata exists and is in the right format" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "npm_add" => "my-plugin@0.1.0",
      }))
      assert_equal ["my-plugin", "0.1.0"], Bridgetown::PluginManager.find_npm_dependency(gem_mock)
    end

    it "works if the metadata package starts with an @ symbol" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "yarn-add" => "@my-org/my-plugin@0.1.0",
      }))
      assert_equal ["@my-org/my-plugin", "0.1.0"], Bridgetown::PluginManager.find_npm_dependency(gem_mock)
    end

    it "does not work if the metadata doesn't exist" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new)
      assert_equal nil, Bridgetown::PluginManager.find_npm_dependency(gem_mock)
    end

    it "does not work if the metadata isn't in the right format" do
      gem_mock = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "npm_add" => "gobbledeegook",
      }))
      assert_equal nil, Bridgetown::PluginManager.find_npm_dependency(gem_mock)

      gem_mock2 = OpenStruct.new(to_spec: OpenStruct.new(metadata: {
        "npm_add" => "gobbledee@gook@",
      }))
      assert_equal nil, Bridgetown::PluginManager.find_npm_dependency(gem_mock2)
    end
  end

  describe "check package.json for dependency information" do
    before do
      @npm_dep = ["@my-org/my-plugin", "0.2.0"]
      @package_json = {
        "dependencies" => {
          "@my-org/my-plugin" => "0.1.0",
        },
      }
    end

    it "does nothing if there's no npm dependency" do
      refute Bridgetown::PluginManager.add_npm_dependency?(nil, @package_json)
    end

    it "green-lights if package_json dependencies is missing" do
      assert Bridgetown::PluginManager.add_npm_dependency?(@npm_dep, {})
    end

    it "green-lights if package_json dependency is old" do
      assert Bridgetown::PluginManager.add_npm_dependency?(@npm_dep, @package_json)
    end

    it "does nothing if package_json dependency is the same" do
      @npm_dep[1] = "0.1.0"
      refute Bridgetown::PluginManager.add_npm_dependency?(@npm_dep, @package_json)
    end

    it "green-lights if package_json dependency wasn't included" do
      @package_json["dependencies"].delete("my-plugin")
      assert Bridgetown::PluginManager.add_npm_dependency?(@npm_dep, @package_json)
    end
  end

  describe "verify npm package" do
    it "installs if entry in package.json is blank" do
      assert Bridgetown::PluginManager.package_requires_updating?(nil, "1.0.0")
    end

    it "installs if entry in package.json is outdated" do
      assert Bridgetown::PluginManager.package_requires_updating?("1.0.0", "1.0.2")
    end

    it "does not install if entry in package.json is the same" do
      refute Bridgetown::PluginManager.package_requires_updating?("1.0.1", "1.0.1")
    end

    it "does not install if entry in package.json a URL or file path" do
      refute Bridgetown::PluginManager.package_requires_updating?("../path", "1.0.1")
      refute Bridgetown::PluginManager.package_requires_updating?("http://domain", "1.0.1")
    end
  end

  describe "plugins_dir is set to the default" do
    it "calls site's in_root_dir" do
      mock = Minitest::Mock.new
      config = {
        "plugins_dir" => Bridgetown::Configuration::DEFAULTS["plugins_dir"],
      }
      2.times do
        mock.expect :config, config
      end
      mock.expect :in_root_dir, nil, ["plugins"]

      plugin_manager = PluginManager.new(mock)
      plugin_manager.plugins_path
      mock.verify
    end
  end

  describe "plugins_dir is set to a different dir" do
    it "expands plugin path" do
      mock = Minitest::Mock.new
      config = {
        "plugins_dir" => "some_other_plugins_path",
      }
      2.times do
        mock.expect :config, config
      end
      file_mock = Minitest::Mock.new
      file_mock.expect :call, nil, ["some_other_plugins_path"]

      plugin_manager = PluginManager.new(mock)
      File.stub :expand_path, file_mock do
        plugin_manager.plugins_path
      end
      mock.verify
      file_mock.verify
    end
  end

  describe "third-party plugins can supply content" do
    before do
      fixture_site.process
    end

    describe "extra component file" do
      before do
        @result = File.read(dest_dir("plugin_content", "components", "index.html"))
      end

      it "correctly renders plugin component" do
        assert_match ":This plugin content should come through:", @result
      end

      it "allows overrides of plugin component" do
        assert_match ":Yay, it got overridden!:", @result
      end
    end

    describe "extra page and static file" do
      before do
        @result = File.read(dest_dir("page_from_a_plugin", "index.html"))
        @static_result = File.read(dest_dir("assets", "static.txt"))
      end

      it "reads plugin page" do
        assert_match "I am a page from a plugin!", @result
        assert_match ":This layout content should come through:", @result
      end

      it "reads static file" do
        assert_match "Static file from a plugin!", @static_result
      end
    end

    describe "extra layout file" do
      before do
        @result = File.read(dest_dir("plugin_content", "layouts", "index.html"))
        @override_result = File.read(dest_dir("plugin_content", "layouts_override", "index.html"))
      end

      it "correctly renders plugin layout" do
        assert_match ":This layout content should come through:", @result
      end

      it "correctly renders overridden layout" do
        assert_match ":This overridden layout SHOULD come through:", @override_result
        assert_match "The layout should have been overridden", @override_result
      end
    end
  end
end
