# frozen_string_literal: true

require "helper"

class TestWebpackCommand < BridgetownUnitTest

  context "the webpack command" do
    setup do
      @site = fixture_site
      @site.process
      @cmd = Bridgetown::Commands::Webpack.new
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
      output = capture_stdout do
        @cmd.invoke(:webpack, ["setup"])
      end
      assert_match %r!fixture.*?Works\!!, output
    end

    should "update webpack config" do
      output = capture_stdout do
        @cmd.invoke(:webpack, ["setup"])
      end
      assert_match %r!fixture.*?Works\!!, output
    end

    should "enable postcss in webpack config" do
      output = capture_stdout do
        @cmd.invoke(:webpack, ["setup"])
      end
      assert_match %r!fixture.*?Works\!!, output
    end
  end
end
