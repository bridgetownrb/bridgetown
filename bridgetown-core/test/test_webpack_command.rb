# frozen_string_literal: true

require "helper"

class TestWebpackCommand < BridgetownUnitTest
  def webpack_defaults
    File.join(@full_path, "config", "webpack.defaults.js")
  end

  def webpack_config
    File.join(@full_path, "webpack.config.js")
  end

  unless ENV["GITHUB_ACTIONS"]
    context "the webpack command" do
      setup do
        @path = "new-site"
        @full_path = File.expand_path(@path, Dir.pwd)

        capture_stdout { Bridgetown::Commands::Base.start(["new", @path]) }
        @cmd = Bridgetown::Commands::Webpack.new
      end

      teardown do
        FileUtils.rm_r @full_path if File.directory?(@full_path)
      end

      should "list all available actions when invoked without args" do
        output = capture_stdout do
          @cmd.webpack
        end
        assert_match %r!setup!, output
        assert_match %r!update!, output
        assert_match %r!enable-postcss!, output
      end

      should "show error when action doesn't exist" do
        output = capture_stdout do
          @cmd.invoke(:webpack, ["qwerty"])
        end

        assert_match %r!Please enter a valid action!, output
      end

      should "setup webpack defaults and config" do
        File.delete webpack_defaults # Delete the file created during setup

        @cmd.inside(@full_path) do
          capture_stdout { @cmd.invoke(:webpack, ["setup"]) }
        end

        assert_exist webpack_defaults
        assert_exist webpack_config
      end

      should "update webpack config" do
        File.write(webpack_defaults, "OLD_VERSION")

        @cmd.inside(@full_path) do
          capture_stdout { @cmd.invoke(:webpack, ["update"]) }
        end

        assert_file_contains %r!module.exports!, webpack_defaults
        refute_file_contains %r!OLD_VERSION!, webpack_defaults
      end

      should "enable postcss in webpack config" do
        refute_file_contains %r!mode: 'postcss'!, webpack_defaults

        @cmd.inside(@full_path) do
          capture_stdout { @cmd.invoke(:webpack, ["enable-postcss"]) }
        end

        assert_file_contains %r!mode: 'postcss'!, webpack_defaults
      end
    end
  end
end
