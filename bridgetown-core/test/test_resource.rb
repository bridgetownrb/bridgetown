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

  context "a resource in a collection with custom filename permalinks" do
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

    should "have transformed content" do
      assert_equal "Fa la la la la la la la la!", @resource.content.strip
    end
  end

  context "a resource in a collection with default permalinks" do
    setup do
      @site = resources_site(
        "collections" => {
          "events" => {
            "output" => true,
          },
        }
      )
      @site.process
      @resource = @site.collections.events.resources[0]
      @dest_file = dest_dir("events/christmas/index.html")
    end

    should "produce the right URL" do
      assert_equal "/events/christmas/", @resource.relative_url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @resource.destination.output_path
    end
  end

  context "a resource in a collection with a :simple_ext permalink style" do
    setup do
      @site = resources_site(
        "collections" => {
          "noodles" => {
            "output"    => true,
            "permalink" => "simple_ext",
          },
        }
      )
      @site.process
      @resource = @site.collections.noodles.resources[1]
      @dest_file = dest_dir("noodles/low-cost/ramen.html")
    end

    should "produce the right URL" do
      assert_equal "/noodles/low-cost/ramen", @resource.relative_url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @resource.destination.output_path
    end

    should "have transformed content" do
      assert_equal "Mmm, yum!", @resource.content.strip
    end

    should "contain default front matter" do
      assert_equal %w[noodle dishes], @resource.data.tags
      assert_equal "dishes", @resource.taxonomies.tag.terms[1].label
    end

    should "appear in page loop" do
      page = @site.collections.pages.resources.find { |pg| pg.data.title == "I'm the Noodles index" }
      assert_includes page.output, "<li>Noodles!: /noodles/low-cost/ramen"
    end
  end

  context "a resource in the posts collection with a weird filename" do
    setup do
      @site = resources_site
      @site.process
      @resource = @site.collections.posts.resources[0]
      @dest_file = dest_dir("2019/09/09/bløg-pöst/index.html")
    end

    should "produce the right URL" do
      assert_equal "/2019/09/09/bløg-pöst/", @resource.relative_url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @resource.destination.output_path
    end

    should "have a fancy title" do
      assert_equal "I'm a bløg pöst? 😄", @resource.data.title
    end
  end

  context "a resource in the posts collection" do
    setup do
      @site = resources_site({ slugify_mode: "latin" })
      @site.process
      @resource = @site.collections.posts.resources[0]
      @dest_file = dest_dir("2019/09/09/blog-post/index.html")
    end

    should "allow a simpler slugify mode" do
      assert_equal "/2019/09/09/blog-post/", @resource.relative_url
      assert_equal @dest_file, @resource.destination.output_path
    end
  end

  context "a resource in a collection that's only a YAML file" do
    setup do
      @site = resources_site(
        "collections" => {
          "noodles" => {
            "output" => true,
          },
        }
      )
      @site.process
      @resource = @site.collections.noodles.resources[0]
    end

    should "have no URL" do
      assert_equal "", @resource.relative_url
    end

    should "have no destination file" do
      assert @resource.destination.nil?
    end

    should "have data" do
      assert_equal 1, @resource.data.data.goes.here
    end

    should "be a static file without triple dashes" do
      assert_equal 2, @site.collections.noodles.resources.length
      assert_equal "static_file.yml", @site.collections.noodles.static_files.first.name
    end
  end

  context "a resource in the data collection" do
    setup do
      @site = resources_site
      @site.process
      @resource = @site.collections.data.resources[0]
    end

    should "have no URL" do
      assert_equal "", @resource.relative_url
    end

    should "have no destination file" do
      assert @resource.destination.nil?
    end

    should "have data" do
      assert_equal "cheese", @resource.data.products.first.name
      assert_equal "cheese", @site.data.categories.dairy.products.first.name
      assert_equal 5.3, @site.data.categories.dairy.products.first.price
    end
  end
end
