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
        @cmd.perform_configuration
      end
      assert_match %r!test_automation!, output
    end
    
    should "list all available configurations when configuration doesn't exist" do
      output = capture_stdout do
        @cmd.invoke(:perform_configuration, ["qwerty"])
      end
      assert_match %r!test_automation!, output
    end
    
    should "perform configuration" do
      output = capture_stdout do
        @cmd.invoke(:perform_configuration, ["test_automation"])
      end
      assert_match %r!fixture.*?Works\!!, output
    end
  end
end