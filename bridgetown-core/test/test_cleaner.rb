# frozen_string_literal: true

require "helper"

class TestCleaner < BridgetownUnitTest
  context "directory in keep_files" do
    setup do
      clear_dest

      FileUtils.mkdir_p(dest_dir("to_keep/child_dir"))
      FileUtils.touch(File.join(dest_dir("to_keep"), "index.html"))
      FileUtils.touch(File.join(dest_dir("to_keep/child_dir"), "index.html"))

      @site = fixture_site
      @site.config.keep_files = ["to_keep/child_dir"]

      @cleaner = Cleaner.new(@site)
      @cleaner.cleanup!
    end

    teardown do
      FileUtils.rm_rf(dest_dir("to_keep"))
    end

    should "keep the parent directory" do
      assert_exist dest_dir("to_keep")
    end

    should "keep the child directory" do
      assert_exist dest_dir("to_keep", "child_dir")
    end

    should "keep the file in the directory in keep_files" do
      assert_exist dest_dir("to_keep", "child_dir", "index.html")
    end

    should "delete the file in the directory not in keep_files" do
      refute_exist dest_dir("to_keep", "index.html")
    end
  end

  context "non-nested directory & similarly-named directory *not* in keep_files" do
    setup do
      clear_dest

      FileUtils.mkdir_p(dest_dir(".git/child_dir"))
      FileUtils.mkdir_p(dest_dir("username.github.io"))
      FileUtils.touch(File.join(dest_dir(".git"), "index.html"))
      FileUtils.touch(File.join(dest_dir("username.github.io"), "index.html"))

      @site = fixture_site
      @site.config.keep_files = [".git"]

      @cleaner = Cleaner.new(@site)
      @cleaner.cleanup!
    end

    teardown do
      FileUtils.rm_rf(dest_dir(".git"))
      FileUtils.rm_rf(dest_dir("username.github.io"))
    end

    should "keep the file in the directory in keep_files" do
      assert File.exist?(File.join(dest_dir(".git"), "index.html"))
    end

    should "delete the file in the directory not in keep_files" do
      assert !File.exist?(File.join(dest_dir("username.github.io"), "index.html"))
    end

    should "delete the directory not in keep_files" do
      assert !File.exist?(dest_dir("username.github.io"))
    end
  end

  context "directory containing no files and non-empty directories" do
    setup do
      clear_dest

      FileUtils.mkdir_p(source_dir("no_files_inside", "child_dir"))
      FileUtils.touch(source_dir("no_files_inside", "child_dir", "index.html"))

      @site = fixture_site
      @site.process

      @cleaner = Cleaner.new(@site)
      @cleaner.cleanup!
    end

    teardown do
      FileUtils.rm_rf(source_dir("no_files_inside"))
      FileUtils.rm_rf(dest_dir("no_files_inside"))
    end

    should "keep the parent directory" do
      assert_exist dest_dir("no_files_inside")
    end

    should "keep the child directory" do
      assert_exist dest_dir("no_files_inside", "child_dir")
    end

    should "keep the file" do
      assert_exist source_dir("no_files_inside", "child_dir", "index.html")
    end
  end
end
