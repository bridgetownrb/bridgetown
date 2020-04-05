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

  context "require gems" do
    should "invoke `require_with_graceful_fail`" do
      gems = %w(jemojii foobar)

      expect(Bridgetown::External).to(
        receive(:require_with_graceful_fail).with(gems).and_return(nil)
      )
      site = double(:gems => gems)
      plugin_manager = PluginManager.new(site)

      plugin_manager.require_gems
    end
  end

  context "site containing plugins" do
    should "require plugin files" do
      site = double(:config        => { "plugins_dir" => "_plugins" },
                    :in_source_dir => "/tmp/")
      plugin_manager = PluginManager.new(site)

      expect(Bridgetown::External).to receive(:require_with_graceful_fail)
      plugin_manager.require_plugin_files
    end
  end

  context "plugins_dir is set to the default" do
    should "call site's in_source_dir" do
      site = double(
        :config        => {
          "plugins_dir" => Bridgetown::Configuration::DEFAULTS["plugins_dir"],
        },
        :in_source_dir => "/tmp/"
      )
      plugin_manager = PluginManager.new(site)

      expect(site).to receive(:in_source_dir).with("_plugins")
      plugin_manager.plugins_path
    end
  end

  context "plugins_dir is set to a different dir" do
    should "expand plugin path" do
      site = double(:config => { "plugins_dir" => "some_other_plugins_path" })
      plugin_manager = PluginManager.new(site)

      expect(File).to receive(:expand_path).with("some_other_plugins_path")
      plugin_manager.plugins_path
    end
  end

  # TODO: rework when plugin-based multiple theme support arrives
  # should "conscientious require" do
  #   site = double(
  #     :config      => { "theme" => "test-dependency-theme" },
  #     :in_dest_dir => "/tmp/_site/"
  #   )
  #   plugin_manager = PluginManager.new(site)

  #   expect(site).to receive(:theme).and_return(true)
  #   expect(site).to receive(:process).and_return(true)
  #   expect(plugin_manager).to(
  #     receive_messages([
  #       :require_theme_deps,
  #       :require_plugin_files,
  #       :require_gems,
  #       :deprecation_checks,
  #     ])
  #   )
  #   plugin_manager.conscientious_require
  #   site.process
  #   assert site.in_dest_dir("test.txt")
  # end
end
