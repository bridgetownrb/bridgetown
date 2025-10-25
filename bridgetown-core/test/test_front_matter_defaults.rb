# frozen_string_literal: true

require "helper"

class TestFrontMatterDefaults < BridgetownUnitTest
  describe "A site with full front matter defaults" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "scope"  => {
            "path"       => "contacts",
            "collection" => "pages",
          },
          "values" => {
            "key" => "val",
          },
        }]
      )
      @output = capture_output { @site.process }
      @affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "contacts/bar.html" }
      @not_affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "about.html" }
    end

    it "affects only the specified path and type" do
      assert_equal "val", @affected.data["key"]
      assert_nil @not_affected.data["key"]
    end

    it "does not call Dir.glob block" do
      refute_includes @output, "Globbed Scope Path:"
    end
  end

  describe "A site with full front matter defaults (glob)" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "scope"  => {
            "path" => "contacts/*.html",
            "type" => "pages",
          },
          "values" => {
            "key" => "val",
          },
        }]
      )
      @output = capture_output { @site.process }
      @affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "contacts/bar.html" }
      @not_affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "about.html" }
    end

    it "affects only the specified path and type" do
      assert_equal "val", @affected.data["key"]
      assert_nil @not_affected.data["key"]
    end

    it "calls Dir.glob block" do
      assert_includes @output, "Globbed Scope Path:"
    end
  end

  describe "A site with front matter type pages and an extension" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "scope"  => {
            "path" => "index.html",
          },
          "values" => {
            "key" => "val",
          },
        }]
      )

      @site.process
      @affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "index.html" }
      @not_affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "about.html" }
    end

    it "affects only the specified path" do
      assert_equal "val", @affected.data["key"]
      assert_nil @not_affected.data["key"]
    end
  end

  # TODO: look into issue where `win/_posts/*` is not getting loaded
  #
  # describe "A site with front matter defaults with no type" do
  #   before do
  #     @site = fixture_site(
  #       "defaults" => [{
  #         "scope"  => {
  #           "path" => "win",
  #         },
  #         "values" => {
  #           "key" => "val",
  #         },
  #       }]
  #     )

  #     @site.process
  #     p @site.resources.find { |page| page.relative_path.to_s =~ %r!win\/! }
  #     @affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s =~ %r!win\/! }
  #     @not_affected = @site.collections.pages.resources.find { |page| page.relative_path.to_s == "about.html" }
  #   end
  #
  #   it "affects only the specified path and all types" do
  #     assert_equal "val", @affected.data["key"]
  #     assert_nil @not_affected.data["key"]
  #   end
  # end

  describe "A site with front matter defaults with no path and a deprecated type" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "scope"  => {
            "type" => "pages",
          },
          "values" => {
            "key" => "val",
          },
        }]
      )

      @site.process
      @affected = @site.collections.pages.resources
      @not_affected = @site.collections.posts.resources
    end

    it "affects only the specified type and all paths" do
      assert_equal @affected.reject { |page| page.data["key"] == "val" }, []
      assert_equal @not_affected.reject { |page| page.data["key"] == "val" },
                   @not_affected
    end
  end

  describe "A site with front matter defaults with no path" do
    before do
      @site = fixture_site
      @site.config.defaults << {
        scope: {
          type: "pages",
        },
        values: {
          key: "val",
        },
      }
      @site.read
      @affected = @site.collections.pages.resources
      @not_affected = @site.collections.posts.resources
    end

    it "affects only the specified type and all paths" do
      assert @affected.length > 1
      assert_equal @affected.reject { |page| page.data["key"] == "val" }, []
      assert_equal @not_affected.reject { |page| page.data["key"] == "val" },
                   @not_affected
    end
  end

  describe "A site with front matter defaults with no path or type" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "scope"  => {},
          "values" => {
            "key" => "val",
          },
        }]
      )
      @site.process
      @affected = @site.collections.pages.resources
      @not_affected = @site.collections.posts.resources
    end

    it "affects all types and paths" do
      assert_equal @affected.reject { |page| page.data["key"] == "val" }, []
      assert_equal @not_affected.reject { |page| page.data["key"] == "val" }, []
    end
  end

  describe "A site with front matter defaults with no scope" do
    before do
      @site = fixture_site(
        "defaults" => [{
          "values" => {
            "key" => "val",
          },
        }]
      )
      @site.process
      @affected = @site.collections.pages.resources
      @not_affected = @site.collections.posts.resources
    end

    it "affects all types and paths" do
      assert_equal @affected.reject { |page| page.data["key"] == "val" }, []
      assert_equal @not_affected.reject { |page| page.data["key"] == "val" }, []
    end
  end

  describe "A site with front matter defaults with quoted date" do
    before do
      @site = fixture_site({
        "defaults" => [{
          "values" => {
            "date" => "2015-01-01 00:00:01",
          },
        }],
      })
    end

    it "parses date" do
      @site.process
      date = Time.parse("2015-01-01 00:00:01")
      assert(@site.collections.pages.resources.find { |page| page.data["date"] == date })
      assert(@site.collections.posts.resources.find { |page| page.data["date"] == date })
    end
  end

  describe "A site with front matter data cascade" do
    before do
      @site = fixture_site
      @site.process
    end

    it "has a post with a value from the defaults file" do
      assert(@site.collections.posts.resources.find { |page| page.data[:title] == "Post with Permalink" }.data[:ruby3] == "groovy")
    end

    it "has an overridden value in a subtree" do
      assert(@site.collections.posts.resources.find { |page| page.data[:title] == "Further Nested" }.data[:ruby3] == "trippin")
    end
  end
end
