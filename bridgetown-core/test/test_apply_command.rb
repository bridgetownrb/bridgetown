# frozen_string_literal: true

require "helper"
require "open-uri"

class TestApplyCommand < BridgetownUnitTest
  unless ENV["GITHUB_ACTIONS"]
    context "the apply command" do
      setup do
        @cmd = Bridgetown::Commands::Apply.new
        FileUtils.rm_rf("bridgetown.automation.rb")
        @template = "" + <<-TEMPLATE
        say_status :urltest, "Works!"
        TEMPLATE
        @template.singleton_class.define_method(:read) do
          @template
        end
      end

      should "automatically run bridgetown.automation.rb" do
        output = capture_stdout do
          @cmd.apply_automation
        end
        assert_match "add bridgetown.automation.rb", output

        File.open("bridgetown.automation.rb", "w") do |f|
          f.puts "say_status :applytest, 'I am Bridgetown. Hear me roar!'"
        end
        output = capture_stdout do
          @cmd.apply_automation
        end
        File.delete("bridgetown.automation.rb")
        assert_match %r!applytest.*?Hear me roar\!!, output
      end

      should "run automations via relative file paths" do
        file = "test/fixtures/test_automation.rb"
        output = capture_stdout do
          @cmd.invoke(:apply_automation, [file])
        end
        assert_match %r!fixture.*?Works\!!, output
      end

      should "run automations from URLs" do
        URI.stub :open, proc { @template } do
          file = "http://randomdomain.com/12345.rb"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end
          assert_match %r!apply.*?http://randomdomain\.com/12345\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "automatically add bridgetown.automation.rb to URL folder path" do
        URI.stub :open, proc { @template } do
          file = "http://randomdomain.com/foo"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end
          assert_match %r!apply.*?http://randomdomain\.com/foo/bridgetown\.automation\.rb!, output
        end
      end

      should "transform GitHub repo URLs automatically" do
        skip "This causes a system stack error when full suite is run—don't know why!"

        URI.stub :open, proc { @template } do
          file = "https://github.com/bridgetownrb/bridgetown-automations"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/main/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "transform GitHub repo URLs and respect branches" do
        URI.stub :open, proc { @template } do
          # file url includes */tree/<branch>/* for a regular github url
          file = "https://github.com/bridgetownrb/bridgetown-automations/tree/my-tree"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/my-tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "transform GitHub repo URLs and preserve directories named 'tree'" do
        URI.stub :open, proc { @template } do
          file = "https://github.com/bridgetownrb/bridgetown-automations/tree/my-tree/tree"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/my-tree/tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "transform GitHub repo URLs and not cause issues if the repo name is 'tree'" do
        URI.stub :open, proc { @template } do
          file = "https://github.com/bridgetown/tree/tree/my-tree/tree"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetown/tree/my-tree/tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "transform GitHub file blob URLs" do
        URI.stub :open, proc { @template } do
          # file url includes */tree/<branch>/* for a regular github url
          file = "https://github.com/bridgetownrb/bridgetown-automations/blob/branchname/folder/file.rb"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/branchname/folder/file.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      should "transform Gist URLs automatically" do
        URI.stub :open, proc { @template } do
          file = "https://gist.github.com/jaredcwhite/963d40acab5f21b42152536ad6847575"
          output = capture_stdout do
            @cmd.invoke(:apply_automation, [file])
          end
          assert_match %r!apply.*?https://gist\.githubusercontent.com/jaredcwhite/963d40acab5f21b42152536ad6847575/raw/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end
    end
  end
end
