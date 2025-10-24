# frozen_string_literal: true

require "helper"

class TestEntryFilter < BridgetownUnitTest
  describe "Filtering entries" do
    before do
      @site = fixture_site
    end

    it "filters entries" do
      ent1 = %w(foo.markdown bar.markdown baz.markdown #baz.markdown#
                .baz.markdow foo.markdown~ .htaccess _posts _pages ~$benbalter.docx)

      entries = EntryFilter.new(@site).filter(ent1)
      assert_equal %w(foo.markdown bar.markdown baz.markdown .htaccess), entries
    end

    it "allows regexp filtering" do
      files = %w(README.md)
      @site.config.exclude = [
        %r!README!,
      ]

      assert_empty @site.reader.filter_entries(
        files
      )
    end

    it "filters entries with exclude" do
      excludes = %w(README TODO vendor/bundle)
      files = %w(index.html site.css .htaccess vendor)

      @site.config.exclude = excludes + ["exclude*"]
      assert_equal files, @site.reader.filter_entries(excludes + files + ["excludeA"])
    end

    it "filters entries with exclude relative to site source" do
      excludes = %w(README TODO css)
      files = %w(index.html vendor/css .htaccess)

      @site.config.exclude = excludes
      assert_equal files, @site.reader.filter_entries(excludes + files + ["css"])
    end

    it "filters excluded directory and contained files" do
      excludes = %w(README TODO css)
      files = %w(index.html .htaccess)

      @site.config.exclude = excludes
      assert_equal(
        files,
        @site.reader.filter_entries(
          excludes + files + ["css", "css/main.css", "css/vendor.css"]
        )
      )
    end

    it "does not filter entries within include" do
      includes = %w(_index.html .htaccess include*)
      files = %w(index.html _index.html .htaccess includeA)

      @site.config.include = includes
      assert_equal files, @site.reader.filter_entries(files)
    end
  end

  describe "#glob_include?" do
    before do
      @site = Site.new(site_configuration)
      @filter = EntryFilter.new(@site)
    end

    it "returns false with no glob patterns" do
      assert !@filter.glob_include?([], "a.txt")
    end

    it "returns false with all not match path" do
      data = ["a*", "b?"]
      assert !@filter.glob_include?(data, "ca.txt")
      assert !@filter.glob_include?(data, "ba.txt")
    end

    it "returns true with match path" do
      data = ["a*", "b?", "**/a*"]
      assert @filter.glob_include?(data, "a.txt")
      assert @filter.glob_include?(data, "ba")
      assert @filter.glob_include?(data, "c/a/a.txt")
      assert @filter.glob_include?(data, "c/a/b/a.txt")
    end

    it "matches even if there is no leading slash" do
      data = ["vendor/bundle"]
      assert @filter.glob_include?(data, "/vendor/bundle")
      assert @filter.glob_include?(data, "vendor/bundle")
    end

    it "matches even if there is no trailing slash" do
      data = ["/vendor/bundle/", "vendor/ruby"]
      assert @filter.glob_include?(data, "vendor/bundle/bridgetown/lib/page.rb")
      assert @filter.glob_include?(data, "/vendor/ruby/lib/set.rb")
    end
  end
end
