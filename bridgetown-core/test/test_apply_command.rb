# frozen_string_literal: true

require "helper"
require "open-uri"

class TestApplyCommand < BridgetownUnitTest
  unless ENV["GITHUB_ACTIONS"]
    describe "the apply command" do
      before do
        @cmd = Bridgetown::Commands::Apply
        FileUtils.rm_rf("bridgetown.automation.rb")
        @template = "" + <<-TEMPLATE
        say_status :urltest, "Works!"
        TEMPLATE
        @template.singleton_class.define_method(:read) do
          @template
        end
      end

      it "automatically runs bridgetown.automation.rb" do
        output = capture_stdout do
          @cmd.()
        end
        assert_match "add bridgetown.automation.rb", output

        File.open("bridgetown.automation.rb", "w") do |f|
          f.puts "say_status :applytest, 'I am Bridgetown. Hear me roar!'"
        end
        output = capture_stdout do
          @cmd.()
        end
        File.delete("bridgetown.automation.rb")
        assert_match %r!applytest.*?Hear me roar\!!, output
      end

      it "runs automations via relative file paths" do
        file = "test/fixtures/test_automation.rb"
        output = capture_stdout do
          @cmd[file].()
        end
        assert_match %r!fixture.*?Works\!!, output
      end

      it "runs automations from URLs" do
        URI.stub :open, proc { @template } do
          file = "http://randomdomain.com/12345.rb"
          output = capture_stdout do
            @cmd[file].()
          end
          assert_match %r!apply.*?http://randomdomain\.com/12345\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "automatically adds bridgetown.automation.rb to URL folder path" do
        URI.stub :open, proc { @template } do
          file = "http://randomdomain.com/foo"
          output = capture_stdout do
            @cmd[file].()
          end
          assert_match %r!apply.*?http://randomdomain\.com/foo/bridgetown\.automation\.rb!, output
        end
      end

      it "transforms GitHub repo URLs automatically" do
        Bridgetown::Utils.stub :default_github_branch_name, proc { "main" } do
          file = "https://github.com/bridgetownrb/bridgetown-automations"
          expect(@cmd[file].send(:transform_automation_url, file)) ==
            "https://raw.githubusercontent.com/bridgetownrb/bridgetown-automations/main/bridgetown.automation.rb"
        end
      end

      it "transforms GitHub repo URLs and respects branches" do
        URI.stub :open, proc { @template } do
          # file url includes */tree/<branch>/* for a regular github url
          file = "https://github.com/bridgetownrb/bridgetown-automations/tree/my-tree"
          output = capture_stdout do
            @cmd[file].()
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/my-tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "transforms GitHub repo URLs and preserves directories named 'tree'" do
        URI.stub :open, proc { @template } do
          file = "https://github.com/bridgetownrb/bridgetown-automations/tree/my-tree/tree"
          output = capture_stdout do
            @cmd[file].()
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/my-tree/tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "transforms GitHub repo URLs and does not cause issues if the repo name is 'tree'" do
        URI.stub :open, proc { @template } do
          file = "https://github.com/bridgetown/tree/tree/my-tree/tree"
          output = capture_stdout do
            @cmd[file].()
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetown/tree/my-tree/tree/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "transforms GitHub file blob URLs" do
        URI.stub :open, proc { @template } do
          # file url includes */tree/<branch>/* for a regular github url
          file = "https://github.com/bridgetownrb/bridgetown-automations/blob/branchname/folder/file.rb"
          output = capture_stdout do
            @cmd[file].()
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://raw\.githubusercontent.com/bridgetownrb/bridgetown-automations/branchname/folder/file.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "transforms Gist URLs automatically" do
        URI.stub :open, proc { @template } do
          file = "https://gist.github.com/jaredcwhite/963d40acab5f21b42152536ad6847575"
          output = capture_stdout do
            @cmd[file].()
          end
          assert_match %r!apply.*?https://gist\.githubusercontent.com/jaredcwhite/963d40acab5f21b42152536ad6847575/raw/bridgetown\.automation\.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end

      it "transforms GitLab repo URLs automatically" do
        Bridgetown::Utils.stub :default_gitlab_branch_name, proc { "main" } do
          file = "https://gitlab.com/bridgetownrb/bridgetown-automations"
          expect(@cmd[file].send(:transform_automation_url, file)) ==
            "https://gitlab.com/bridgetownrb/bridgetown-automations/-/raw/main/bridgetown.automation.rb"
        end
      end

      it "transforms Codeberg repo URLs automatically" do
        Bridgetown::Utils.stub :default_codeberg_branch_name, proc { "main" } do
          file = "https://codeberg.org/bridgetownrb/bridgetown-automations"
          expect(@cmd[file].send(:transform_automation_url, file)) ==
            "https://codeberg.org/bridgetownrb/bridgetown-automations/raw/branch/main/bridgetown.automation.rb"
        end
      end

      it "transforms CodeBerg file blob URLs" do
        URI.stub :open, proc { @template } do
          file = "https://codeberg.org/bridgetownrb/bridgetown-automations/src/branch/branchname/folder/file.rb"
          output = capture_stdout do
            @cmd[file].()
          end

          # when pulling raw content, */tree/<branch>/* transforms to */<branch>/*
          assert_match %r!apply.*?https://codeberg.org/bridgetownrb/bridgetown-automations/raw/branch/branchname/folder/file.rb!, output
          assert_match %r!urltest.*?Works\!!, output
        end
      end
    end
  end
end
