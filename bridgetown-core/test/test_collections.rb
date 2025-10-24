# frozen_string_literal: true

require "helper"

class TestCollections < BridgetownUnitTest
  describe "an evil collection" do
    before do
      @collection = Bridgetown::Collection.new(fixture_site, "../../etc/password")
    end

    it "sanitizes the label name" do
      assert_equal "....etcpassword", @collection.label
    end

    it "has a sanitized relative path name" do
      assert_equal "_....etcpassword", @collection.relative_directory
    end

    it "has a sanitized full path" do
      assert_equal @collection.directory, source_dir("_....etcpassword")
    end
  end

  describe "a simple collection" do
    before do
      @collection = Bridgetown::Collection.new(fixture_site, "methods")
    end

    it "sanitizes the label name" do
      assert_equal "methods", @collection.label
    end

    it "has a default URL template" do
      assert_equal "/:locale/:collection/:path/", @collection.default_permalink
    end

    it "contains no docs when initialized" do
      assert_empty @collection.resources
    end

    it "knows its relative directory" do
      assert_equal "_methods", @collection.relative_directory
    end

    it "knows the full path to itself on the filesystem" do
      assert_equal @collection.directory, source_dir("_methods")
    end

    describe "when turned into Liquid" do
      it "has a label attribute" do
        assert_equal "methods", @collection.to_liquid["label"]
      end

      it "has a static_files attribute" do
        assert_equal [], @collection.to_liquid["static_files"]
      end

      it "has a relative_path attribute" do
        assert_equal "_methods", @collection.to_liquid["relative_path"]
      end

      it "has an output attribute" do
        assert_equal false, @collection.to_liquid["output"]
      end
    end

    it "knows whether it should be written or not" do
      assert_equal false, @collection.write?
      @collection.metadata["output"] = true
      assert_equal true, @collection.write?
      @collection.metadata.delete "output"
    end
  end

  describe "with no collections specified" do
    before do
      @site = fixture_site
      @site.process
    end

    it "contains only the default collections" do
      expected = {}
      refute_equal expected, @site.collections
      refute_nil @site.collections
    end
  end

  describe "a collection with permalink" do
    before do
      @site = fixture_site(
        "collections" => {
          "methods" => {
            "permalink" => "/awesome/:path/",
          },
        }
      )
      @site.process
      @collection = @site.collections["methods"]
    end

    it "has a custom permalink" do
      assert_equal "/awesome/:path/", @collection.default_permalink
    end
  end

  describe "with a collection" do
    before do
      @site = fixture_site(
        "collections" => ["methods"]
      )
      @site.process
      @collection = @site.collections["methods"]
    end

    it "creates a Hash mapping label to Collection instance" do
      assert @site.collections.is_a?(Hash)
      refute_nil @site.collections["methods"]
      assert @site.collections["methods"].is_a? Bridgetown::Collection
    end

    it "collects resources in an array on the Collection object" do
      assert @site.collections["methods"].resources.is_a? Array
      @site.collections["methods"].resources.each do |doc|
        assert doc.is_a? Bridgetown::Resource::Base
        # rubocop:disable Style/WordArray
        assert_includes %w(
          _methods/configuration.md
          _methods/sanitized_path.md
          _methods/collection/entries
          _methods/site/generate.md
          _methods/site/initialize.md
          _methods/um_hi.md
          _methods/escape-+\ #%20[].md
          _methods/yaml_with_dots.md
          _methods/3940394-21-9393050-fifif1323-test.md
          _methods/trailing-dots...md
        ), doc.relative_path.to_s
        # rubocop:enable Style/WordArray
      end
    end

    it "does not include the underscored files in the list of docs" do
      refute_includes @collection.resources.map { _1.relative_path.to_s }, "_methods/_do_not_read_me.md"
      refute_includes @collection.resources.map { _1.relative_path.to_s },
                      "_methods/site/_dont_include_me_either.md"
    end
  end

  describe "with a collection with metadata" do
    before do
      @site = fixture_site(
        "collections" => {
          "methods" => {
            "foo" => "bar",
            "baz" => "whoo",
          },
        }
      )
      @site.process
      @collection = @site.collections["methods"]
    end

    it "extracts the configuration collection information as metadata" do
      expected = { "foo" => "bar", "baz" => "whoo" }
      assert_equal expected, @collection.metadata
    end
  end

  describe "with a collection with metadata to sort items by attribute" do
    before do
      @site = fixture_site(
        "collections" => {
          "methods"   => {
            "output" => true,
          },
          "tutorials" => {
            "output"  => true,
            "sort_by" => "lesson",
          },
        }
      )
      @site.process
      @tutorials_collection = @site.collections["tutorials"]

      @actual_array = @tutorials_collection.resources.map { _1.relative_path.to_s }
    end

    it "sorts documents in a collection with 'sort_by' metadata set to a " \
       "FrontMatter key 'lesson'" do
      default_tutorials_array = %w(
        _tutorials/dive-in-and-publish-already.md
        _tutorials/extending-with-plugins.md
        _tutorials/getting-started.md
        _tutorials/graduation-day.md
        _tutorials/lets-roll.md
        _tutorials/tip-of-the-iceberg.md
      )
      tutorials_sorted_by_lesson_array = %w(
        _tutorials/getting-started.md
        _tutorials/lets-roll.md
        _tutorials/dive-in-and-publish-already.md
        _tutorials/tip-of-the-iceberg.md
        _tutorials/extending-with-plugins.md
        _tutorials/graduation-day.md
      )
      refute_equal default_tutorials_array, @actual_array
      assert_equal tutorials_sorted_by_lesson_array, @actual_array
    end
  end

  describe "with a collection with symbol sort_by in config/initializers.rb" do
    before do
      @site = fixture_site(
        "collections" => {
          "tutorials" => {
            "output"  => true,
            "sort_by" => :lesson,
          },
        }
      )
      @site.process
      @tutorials_collection = @site.collections["tutorials"]

      @actual_array = @tutorials_collection.resources.map { _1.relative_path.to_s }
    end

    it "sorts documents in a collection with 'sort_by' metadata set to a " \
       "FrontMatter key symbol :lesson" do
      default_tutorials_array = %w(
        _tutorials/dive-in-and-publish-already.md
        _tutorials/extending-with-plugins.md
        _tutorials/getting-started.md
        _tutorials/graduation-day.md
        _tutorials/lets-roll.md
        _tutorials/tip-of-the-iceberg.md
      )
      tutorials_sorted_by_lesson_array = %w(
        _tutorials/getting-started.md
        _tutorials/lets-roll.md
        _tutorials/dive-in-and-publish-already.md
        _tutorials/tip-of-the-iceberg.md
        _tutorials/extending-with-plugins.md
        _tutorials/graduation-day.md
      )

      refute_equal default_tutorials_array, @actual_array
      assert_equal tutorials_sorted_by_lesson_array, @actual_array
    end
  end

  describe "with a collection with symbol sort_direction in config/initializers.rb" do
    before do
      @site = fixture_site(
        "collections" => {
          "tutorials" => {
            "output"         => true,
            "sort_by"        => :lesson,
            "sort_direction" => :descending,
          },
        }
      )
      @site.process
      @tutorials_collection = @site.collections["tutorials"]

      @actual_array = @tutorials_collection.resources.map { _1.relative_path.to_s }
    end

    it "sorts documents in a collection with 'sort_direction' metadata set to a " \
       "symbol :descending" do
      default_tutorials_array = %w(
        _tutorials/dive-in-and-publish-already.md
        _tutorials/extending-with-plugins.md
        _tutorials/getting-started.md
        _tutorials/graduation-day.md
        _tutorials/lets-roll.md
        _tutorials/tip-of-the-iceberg.md
      )
      tutorials_sorted_by_lesson_desc_array = %w(
        _tutorials/graduation-day.md
        _tutorials/extending-with-plugins.md
        _tutorials/tip-of-the-iceberg.md
        _tutorials/dive-in-and-publish-already.md
        _tutorials/lets-roll.md
        _tutorials/getting-started.md
      )

      refute_equal default_tutorials_array, @actual_array
      assert_equal tutorials_sorted_by_lesson_desc_array, @actual_array
    end
  end

  describe "with dots in the filenames" do
    before do
      @site = fixture_site(
        "collections" => ["with.dots"]
      )
      @site.process
      @collection = @site.collections["with.dots"]
    end

    it "exists" do
      refute_nil @collection
    end

    it "contains one document" do
      assert_equal 4, @collection.resources.size
    end

    it "allows dots in the filename" do
      assert_equal "_with.dots", @collection.relative_directory
    end

    it "reads document in subfolders with dots" do
      assert(
        @collection.resources.any? { |d| d.path.include?("all.dots") }
      )
    end
  end

  describe "a collection with included dotfiles" do
    before do
      @site = fixture_site(
        "collections" => {
          "methods" => {
            "permalink" => "/awesome/:path/",
          },
        },
        "include"     => %w(.htaccess .gitignore)
      )
      @site.process
      @collection = @site.collections["methods"]
    end

    it "contains .htaccess file" do
      assert(@collection.static_files.any? { |d| d.name == ".htaccess" })
    end

    it "contains .gitignore file" do
      assert(@collection.static_files.any? { |d| d.name == ".gitignore" })
    end

    it "has custom URL in static file" do
      assert(
        @collection.static_files.any? { |d| d.url.include?("/awesome/with.dots/") }
      )
    end
  end
end
