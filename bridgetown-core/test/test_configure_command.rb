# frozen_string_literal: true

require "helper"

class TestConfigureCommand < BridgetownUnitTest
  def configurations_path
    File.expand_path(root_dir("lib", "bridgetown-core", "configurations"), __dir__)
  end

  context "the configure command" do
    setup do
      FileUtils.cp(test_dir("fixtures", "test_automation.rb"), configurations_path)
      @cmd = Bridgetown::Commands::Configure.new
    end

    teardown do
      File.delete("#{configurations_path}/test_automation.rb")
    end

    should "list all available configurations when invoked without args" do
      output = capture_stdout do
        @cmd.perform_configurations
      end
      assert_match %r!test_automation!, output
    end

    should "show error when configuration doesn't exist" do
      output = capture_stdout do
        @cmd.invoke(:perform_configurations, ["qwerty"])
      end
      assert_match %r!Configuration doesn't exist: qwerty!, output
    end

    should "perform configuration" do
      output = capture_stdout do
        @cmd.invoke(:perform_configurations, ["test_automation"])
      end
      assert_match %r!fixture.*?Works\!!, output
    end

    should "perform multiple configurations" do
      File.open("#{configurations_path}/roar.rb", "w") do |f|
        f.puts "say_status :applytest, 'I am Bridgetown. Hear me roar!'"
      end

      output = capture_stdout do
        @cmd.invoke(:perform_configurations, %w[test_automation roar fail])
      end
      assert_match %r!fixture.*?Works\!!, output
      assert_match %r!applytest.*?Hear me roar\!!, output
      assert_match %r!Configuration doesn't exist: fail!, output

      File.delete("#{configurations_path}/roar.rb")
    end
  end
end
