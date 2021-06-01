# frozen_string_literal: true

require "helper"

class TestPathSanitization < BridgetownUnitTest
  context "on Windows with absolute source" do
    setup do
      @source = "C:/Users/xmr/Desktop/mpc-hc.org"
      @dest   = "./_site/"
      allow(Dir).to receive(:pwd).and_return("C:/Users/xmr/Desktop/mpc-hc.org")
    end
    should "strip drive name from path" do
      assert_equal "C:/Users/xmr/Desktop/mpc-hc.org/_site",
                   Bridgetown.sanitized_path(@source, @dest)
    end

    should "strip just the initial drive name" do
      assert_equal "/tmp/foobar/jail/..c:/..c:/..c:/etc/passwd",
                   Bridgetown.sanitized_path("/tmp/foobar/jail", "..c:/..c:/..c:/etc/passwd")
    end
  end

  should "escape tilde" do
    assert_equal source_dir("~hi.txt"), Bridgetown.sanitized_path(source_dir, "~hi.txt")
    assert_equal source_dir("files", "~hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "files/../files/~hi.txt")
  end

  should "remove path traversals" do
    assert_equal source_dir("files", "hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "f./../../../../../../files/hi.txt")
  end

  should "strip extra slashes in questionable path" do
    subdir = "/files/"
    file_path = "/hi.txt"
    assert_equal source_dir("files", "hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "/#{subdir}/#{file_path}")
  end

  should "not strip base path if file path has matching prefix" do
    assert_equal "/site/sitemap.xml",
                 Bridgetown.sanitized_path("/site", "sitemap.xml")
  end
end
