# frozen_string_literal: true

require "helper"

class TestCollections < BridgetownUnitTest
  context "an evil collection" do
    setup do
      @collection = Bridgetown::Collection.new(fixture_site, "../../etc/password")
    end

    should "sanitize the label name" do
      assert_equal "....etcpassword", @collection.label
    end

    should "have a sanitized relative path name" do
      assert_equal "_....etcpassword", @collection.relative_directory
    end

    should "have a sanitized full path" do
      assert_equal @collection.directory, source_dir("_....etcpassword")
    end
  end

  context "a simple collection" do
    setup do
      @collection = Bridgetown::Collection.new(fixture_site, "methods")
    end

    should "sanitize the label name" do
      assert_equal "methods", @collection.label
    end

    should "have default URL template" do
      assert_equal "/:locale/:collection/:path/", @collection.default_permalink
    end

    should "contain no docs when initialized" do
      assert_empty @collection.resources
    end

    should "know its relative directory" do
      assert_equal "_methods", @collection.relative_directory
    end

    should "know the full path to itself on the filesystem" do
      assert_equal @collection.directory, source_dir("_methods")
    end

    context "when turned into Liquid" do
      should "have a label attribute" do
        assert_equal "methods", @collection.to_liquid["label"]
      end

      should "have a files attribute" do
        assert_equal [], @collection.to_liquid["files"]
      end

      should "have a relative_path attribute" do
        assert_equal "_methods", @collection.to_liquid["relative_path"]
      end

      should "have a output attribute" do
        assert_equal false, @collection.to_liquid["output"]
      end
    end

    should "know whether it should be written or not" do
      assert_equal false, @collection.write?
      @collection.metadata["output"] = true
      assert_equal true, @collection.write?
      @collection.metadata.delete "output"
    end
  end

  context "with no collections specified" do
    setup do
      @site = fixture_site
      @site.process
    end

    should "contain only the default collections" do
      expected = {}
      refute_equal expected, @site.collections
      refute_nil @site.collections
    end
  end

  context "a collection with permalink" do
    setup do
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

    should "have a custom permalink" do
      assert_equal "/awesome/:path/", @collection.default_permalink
    end
  end

  context "with a collection" do
    setup do
      @site = fixture_site(
        "collections" => ["methods"]
      )
      @site.process
      @collection = @site.collections["methods"]
    end

    should "create a Hash mapping label to Collection instance" do
      assert @site.collections.is_a?(Hash)
      refute_nil @site.collections["methods"]
      assert @site.collections["methods"].is_a? Bridgetown::Collection
    end

    should "collects resources in an array on the Collection object" do
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

    should "not include the underscored files in the list of docs" do
      refute_includes @collection.resources.map { _1.relative_path.to_s }, "_methods/_do_not_read_me.md"
      refute_includes @collection.resources.map { _1.relative_path.to_s },
                      "_methods/site/_dont_include_me_either.md"
    end
  end

  context "with a collection with metadata" do
    setup do
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

    should "extract the configuration collection information as metadata" do
      expected = { "foo" => "bar", "baz" => "whoo" }
      assert_equal expected, @collection.metadata
    end
  end

  context "with a collection with metadata to sort items by attribute" do
    setup do
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

    should "sort documents in a collection with 'sort_by' metadata set to a " \
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

  context "with dots in the filenames" do
    setup do
      @site = fixture_site(
        "collections" => ["with.dots"]
      )
      @site.process
      @collection = @site.collections["with.dots"]
    end

    should "exist" do
      refute_nil @collection
    end

    should "contain one document" do
      assert_equal 4, @collection.resources.size
    end

    should "allow dots in the filename" do
      assert_equal "_with.dots", @collection.relative_directory
    end

    should "read document in subfolders with dots" do
      assert(
        @collection.resources.any? { |d| d.path.include?("all.dots") }
      )
    end
  end

  context "a collection with included dotfiles" do
    setup do
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

    should "contain .htaccess file" do
      assert(@collection.static_files.any? { |d| d.name == ".htaccess" })
    end

    should "contain .gitignore file" do
      assert(@collection.static_files.any? { |d| d.name == ".gitignore" })
    end

    should "have custom URL in static file" do
      assert(
        @collection.static_files.any? { |d| d.url.include?("/awesome/with.dots/") }
      )
    end
  end
end
