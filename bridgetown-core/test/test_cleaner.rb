# frozen_string_literal: true

require "helper"

class TestCleaner < BridgetownUnitTest
  describe "directory in keep_files" do
    before do
      clear_dest

      FileUtils.mkdir_p(dest_dir("to_keep/child_dir"))
      FileUtils.touch(File.join(dest_dir("to_keep"), "index.html"))
      FileUtils.touch(File.join(dest_dir("to_keep/child_dir"), "index.html"))

      @site = fixture_site
      @site.config.keep_files = ["to_keep/child_dir"]

      @cleaner = Cleaner.new(@site)
      @cleaner.cleanup!
    end

    after do
      FileUtils.rm_rf(dest_dir("to_keep"))
    end

    it "keeps the parent directory" do
      assert_exist dest_dir("to_keep")
    end

    it "keeps the child directory" do
      assert_exist dest_dir("to_keep", "child_dir")
    end

    it "keeps the file in the directory in keep_files" do
      assert_exist dest_dir("to_keep", "child_dir", "index.html")
    end

    it "deletes the file in the directory not in keep_files" do
      refute_exist dest_dir("to_keep", "index.html")
    end
  end

  describe "non-nested directory & similarly-named directory *not* in keep_files" do
    before do
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

    after do
      FileUtils.rm_rf(dest_dir(".git"))
      FileUtils.rm_rf(dest_dir("username.github.io"))
    end

    it "keeps the file in the directory in keep_files" do
      assert File.exist?(File.join(dest_dir(".git"), "index.html"))
    end

    it "deletes the file in the directory not in keep_files" do
      assert !File.exist?(File.join(dest_dir("username.github.io"), "index.html"))
    end

    it "deletes the directory not in keep_files" do
      assert !File.exist?(dest_dir("username.github.io"))
    end
  end

  describe "directory containing no files and non-empty directories" do
    before do
      clear_dest

      FileUtils.mkdir_p(source_dir("no_files_inside", "child_dir"))
      FileUtils.touch(source_dir("no_files_inside", "child_dir", "index.html"))

      @site = fixture_site
      @site.process

      @cleaner = Cleaner.new(@site)
      @cleaner.cleanup!
    end

    after do
      FileUtils.rm_rf(source_dir("no_files_inside"))
      FileUtils.rm_rf(dest_dir("no_files_inside"))
    end

    it "keeps the parent directory" do
      assert_exist dest_dir("no_files_inside")
    end

    it "keeps the child directory" do
      assert_exist dest_dir("no_files_inside", "child_dir")
    end

    it "keeps the file" do
      assert_exist source_dir("no_files_inside", "child_dir", "index.html")
    end
  end
end
