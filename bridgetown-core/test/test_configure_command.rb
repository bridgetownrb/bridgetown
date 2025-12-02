# frozen_string_literal: true

require "helper"

class TestConfigureCommand < BridgetownUnitTest
  def configurations_path
    File.expand_path(root_dir("lib", "bridgetown-core", "configurations"), __dir__)
  end

  describe "the configure command" do
    before do
      FileUtils.cp(testing_dir("fixtures", "test_automation.rb"), configurations_path)
      @cmd = Bridgetown::Commands::Configure
    end

    after do
      File.delete("#{configurations_path}/test_automation.rb")
    end

    it "lists all available configurations when invoked without args" do
      output = capture_stdout do
        @cmd.()
      end
      assert_match %r!test_automation!, output
    end

    it "shows error when configuration doesn't exist" do
      output = capture_stdout do
        @cmd["qwerty"].()
      end
      assert_match %r!Configuration doesn't exist: qwerty!, output
    end

    it "performs configuration" do
      output = capture_stdout do
        @cmd["test_automation"].()
      end
      assert_match %r!fixture.*?Works\!!, output
    end

    it "performs multiple configurations" do
      File.open("#{configurations_path}/roar.rb", "w") do |f|
        f.puts "say_status :applytest, 'I am Bridgetown. Hear me roar!'"
      end

      output = capture_stdout do
        @cmd[*%w[test_automation roar fail]].()
      end
      assert_match %r!fixture.*?Works\!!, output
      assert_match %r!applytest.*?Hear me roar\!!, output
      assert_match %r!Configuration doesn't exist: fail!, output

      File.delete("#{configurations_path}/roar.rb")
    end
  end
end
