# frozen_string_literal: true

require "helper"

class TestResource < BridgetownUnitTest
  context "a top-level page" do
    setup do
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resource = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "top-level-page.md"
      end
    end

    should "exist" do
      assert !@resource.nil?
    end

    should "know its relative path" do
      assert_equal "top-level-page.md", @resource.relative_path.to_s
    end

    should "knows its extname" do
      assert_equal ".md", @resource.extname
    end

    should "know its basename without extname" do
      assert_equal "top-level-page", @resource.basename_without_ext
    end

    should "know its collection" do
      assert_equal "pages", @resource.collection.label
    end

    should "know whether it's a YAML file" do
      assert_equal false, @resource.yaml_file?
    end

    should "know its data" do
      assert_equal "I'm a Top Level Page!", @resource.data.title
    end

    should "know its date" do
      assert_equal Time.now.strftime("%Y/%m/%d"), @resource.date.strftime("%Y/%m/%d")
      assert_equal Time.now.strftime("%Y/%m/%d"), @resource.to_liquid["date"].strftime("%Y/%m/%d")
    end

    should "have untransformed and transformed content" do
      assert_equal "That's **great**!", @resource.untransformed_content
      assert_equal "<p>That’s <strong>great</strong>!</p>", @resource.content.strip
    end
  end

  context "a second-level page" do
    setup do
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resource = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "_pages/second-level-page.md"
      end
    end

    should "exist" do
      assert !@resource.nil?
    end

    should "have the correct permalink" do
      assert_equal "/second-level-page/", @resource.relative_url
    end
  end

  context "a document in a collection with custom filename permalinks" do
    setup do
      @site = resources_site(
        "collections" => {
          "events" => {
            "output"    => true,
            "permalink" => "/special_events/:year/:slug.*",
          },
        }
      )
      @site.process
      @resource = @site.collections.events.resources[0]
      @dest_file = dest_dir("special_events/2020/christmas.html")
    end

    should "produce the right URL" do
      assert_equal "/special_events/2020/christmas", @resource.relative_url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @resource.destination.output_path
    end

    should "honor the output extension of its permalink" do
      assert_equal ".html", @resource.destination.output_ext
    end
  end
end
