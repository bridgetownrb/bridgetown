# frozen_string_literal: true

require "helper"

class TestEsbuildCommand < BridgetownUnitTest
  def esbuild_defaults
    File.join(@full_path, "config", "esbuild.defaults.js")
  end

  def esbuild_config
    File.join(@full_path, "esbuild.config.js")
  end

  def package_json_file
    File.join(@full_path, "package.json")
  end

  def rakefile
    File.join(@full_path, "Rakefile")
  end

  context "the esbuild command" do
    setup do
      @path = SecureRandom.alphanumeric
      FileUtils.mkdir_p(File.expand_path("../tmp", __dir__))
      @full_path = File.join(File.expand_path("../tmp", __dir__), @path)

      capture_stdout { Bridgetown::Commands::Base.start(["new", @full_path, "-e", "esbuild"]) }
      @cmd = Bridgetown::Commands::Esbuild.new
    end

    teardown do
      FileUtils.rm_r @full_path if File.directory?(@full_path)
    end

    should "list all available actions when invoked without args" do
      output = capture_stdout do
        @cmd.esbuild
      end
      assert_match %r!setup!, output
      assert_match %r!update!, output
      assert_match %r!migrate-from-webpack!, output
    end

    should "show error when action doesn't exist" do
      output = capture_stdout do
        @cmd.invoke(:esbuild, ["qwerty"])
      end

      assert_match %r!Please enter a valid action!, output
    end

    should "setup esbuild defaults and config" do
      File.delete esbuild_defaults # Delete the file created during setup

      @cmd.inside(@full_path) do
        capture_stdout { @cmd.invoke(:esbuild, ["setup"]) }
      end

      assert_exist esbuild_defaults
      assert_exist esbuild_config
    end

    should "update esbuild config" do
      File.write(esbuild_defaults, "OLD_VERSION")

      @cmd.inside(@full_path) do
        capture_stdout { @cmd.invoke(:esbuild, ["update"]) }
      end

      assert_file_contains %r!module.exports!, esbuild_defaults
      refute_file_contains %r!OLD_VERSION!, esbuild_defaults
    end
  end
end
