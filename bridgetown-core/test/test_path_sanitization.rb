# frozen_string_literal: true

require "helper"

class TestPathSanitization < BridgetownUnitTest
  describe "on Windows with absolute source" do
    before do
      @source = "C:/Users/xmr/Desktop/mpc-hc.org"
      @dest   = "./_site/"
    end

    it "strips drive name from path" do
      Dir.stub :pwd, @source do
        assert_equal "C:/Users/xmr/Desktop/mpc-hc.org/_site",
                     Bridgetown.sanitized_path(@source, @dest)
      end
    end

    it "strips just the initial drive name" do
      Dir.stub :pwd, @source do
        assert_equal "/tmp/foobar/jail/..c:/..c:/..c:/etc/passwd",
                     Bridgetown.sanitized_path("/tmp/foobar/jail", "..c:/..c:/..c:/etc/passwd")
      end
    end
  end

  it "escapes tilde" do
    assert_equal source_dir("~hi.txt"), Bridgetown.sanitized_path(source_dir, "~hi.txt")
    assert_equal source_dir("files", "~hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "files/../files/~hi.txt")
  end

  it "removes path traversals" do
    assert_equal source_dir("files", "hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "f./../../../../../../files/hi.txt")
  end

  it "strips extra slashes in questionable path" do
    subdir = "/files/"
    file_path = "/hi.txt"
    assert_equal source_dir("files", "hi.txt"),
                 Bridgetown.sanitized_path(source_dir, "/#{subdir}/#{file_path}")
  end

  it "does not strip base path if file path has matching prefix" do
    assert_equal "/site/sitemap.xml",
                 Bridgetown.sanitized_path("/site", "sitemap.xml")
  end
end
