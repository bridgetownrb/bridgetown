# frozen_string_literal: true

require "helper"

class TestGeneratedSite < BridgetownUnitTest
  context "generated sites" do
    setup do
      clear_dest

      @site = fixture_site
      @site.process
      @index = File.read(
        dest_dir("index.html"),
        **Utils.merged_file_read_opts(@site, {})
      )
    end

    should "ensure post count is as expected" do
      assert_equal 52, @site.collections.posts.resources.size
    end

    should "insert site.posts into the index" do
      assert_includes @index, "#{@site.collections.posts.resources.size} Posts"
    end

    should "insert variable from layout into the index" do
      assert_includes @index, "variable from layout"
    end

    should "render latest post's content" do
      assert_includes @index, @site.collections.posts.resources.first.content
    end

    should "hide unpublished posts" do
      published = Dir[dest_dir("publish_test/2008/02/02/published/*.html")].map \
        { |f| File.basename(f) }
      assert_equal 1, published.size
    end

    should "hide unpublished page" do
      refute_exist dest_dir("/unpublished.html")
    end

    should "not copy _posts directory" do
      refute_exist dest_dir("_posts")
    end

    should "process a page with a folder permalink properly" do
      about = @site.collections.pages.resources.find { |page| page.relative_path.basename.to_s == "about.html" }
      assert_equal dest_dir("about", "index.html"), about.destination.output_path
      assert_exist dest_dir("about", "index.html")
    end

    should "process other static files and generate correct permalinks" do
      assert_exist dest_dir("contacts/index.html")
      assert_exist dest_dir("dynamic_file.php")
    end

    should "include a post with a abbreviated dates" do
      refute_nil(
        @site.collections.posts.resources.index do |post|
          post.relative_path.to_s == "_posts/2017-2-5-i-dont-like-zeroes.md"
        end
      )
      assert_exist dest_dir("2017", "02", "05", "i-dont-like-zeroes", "index.html")
    end

    should "print a nice list of static files" do
      time_regexp = "\\d+:\\d+"
      #
      # adding a pipe character at the beginning preserves formatting with newlines
      expected_output = Regexp.new <<~OUTPUT
        | - /css/screen.css last edited at #{time_regexp} with extname .css
          - /pgp.key last edited at #{time_regexp} with extname .key
          - /products.yml last edited at #{time_regexp} with extname .yml
          - /symlink-test/symlinked-dir/screen.css last edited at #{time_regexp} with extname .css
      OUTPUT
      assert_match expected_output, File.read(dest_dir("static_files", "index.html"))
    end
  end
end
