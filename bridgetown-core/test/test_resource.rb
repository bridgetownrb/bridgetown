# frozen_string_literal: true

require "helper"

class TestResource < BridgetownUnitTest
  # The test suite is more stable when this is run first separately
  unless ENV["BYPASS_RESOURCE_TEST"]
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

      should "know its layout" do
        assert_equal "default", @resource.layout.label
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
        assert_equal "That's **great**!", @resource.untransformed_content.lines.first.strip
        assert_equal "<p>That’s <strong>great</strong>!</p>", @resource.content.lines.first.strip
      end
    end

    context "a second-level page" do
      setup do
        @site = resources_site
        @site.process
        # @type [Bridgetown::Resource::Base]
        @resource = @site.collections.pages.resources.find do |page|
          page.relative_path.to_s == "_pages/second-level-page.en.md"
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
        assert File.exist?(@dest_file)
      end

      should "honor the output extension of its permalink" do
        assert_equal ".html", @resource.destination.output_ext
      end

      should "have transformed content" do
        assert_equal "Christmas 2020", @resource.data.title
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

    context "a resource that's configured not to output" do
      setup do
        @site = resources_site(
          "collections" => {
            "events" => {
              "output" => true,
            },
          }
        )
        @site.process
        @resource = @site.collections.events.resources[1]
        @dest_file = dest_dir("events/the-weeknd/index.html")
      end

      should "not have any URL" do
        assert_equal "", @resource.relative_url
      end

      should "not have any destination file" do
        assert_nil @resource.destination
        refute File.exist?(@dest_file)
      end

      should "still have processed content" do
        assert_equal "Ladies and gentlemen, The Weeknd!", @resource.content
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

      should "include content" do
        assert_equal "<p>W00t!</p>\n", @resource.content
      end

      should "properly load front matter defaults" do
        assert_equal "present and accounted for", @resource.data.defaults_are
        assert_equal "present and accounted for", {}.merge(@resource.data.to_h)["defaults_are"]
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

      should "not overwrite data in same folder" do
        assert_equal "1.jpg", @site.data.gallery.album_1.file
        assert_equal "2.jpg", @site.data.gallery.album_2.file
        assert_equal "3.jpg", @site.data.gallery.album_1.interior.file
      end
    end

    context "a Ruby data resource" do
      should "provide an array" do
        @site = resources_site
        @site.process
        assert_equal "ruby", @site.data.languages[1]
      end
    end

    context "a PORT (Plain Ol' Ruby Template)" do
      should "render out as HTML" do
        @site = resources_site
        @site.process
        @dest_file = File.read(dest_dir("i-am-ruby/index.html"))

        assert_includes @dest_file, <<~HTML
          <body>
          <blockquote>
            <p>Well, <em>this</em> is quite interesting! =)</p>
          </blockquote>
          </body>
        HTML
      end
    end

    context "dotfile permalink" do
      should "get saved to destination" do
        @site = resources_site
        @site.process
        @dest_file = File.read(dest_dir(".nojekyll"))

        assert_equal "nojekyll", @dest_file.strip
      end
    end

    context "previous and next resource methods" do
      should "return the correct resource" do
        @site = resources_site
        @site.process
        @resource = @site.collections.pages.resources[0]

        assert_equal @site.collections.pages.resources[1], @resource.next_resource
        assert_equal @site.collections.pages.resources[0], @resource.next_resource.previous_resource
      end
    end

    context "prototype pages" do
      setup do
        @site = resources_site
        @site.process
        @page = @site.generated_pages.find { |page| page.data.title == "Noodles Archive" }
        @dest_file = dest_dir("noodle-archive/ramen/index.html")
      end

      should "be generated for the given term" do
        assert File.exist?(@dest_file)
        assert_includes @page.output, "<h1>ramen</h1>"
      end

      should "not persist across rebuilds" do
        page_count = @site.generated_pages.size
        Bridgetown::Hooks.trigger :site, :pre_reload, @site
        @site.process
        assert_equal page_count, @site.generated_pages.size
      end
    end

    context "resource extensions" do
      setup do
        @site = resources_site
        @site.process
      end

      should "augment the Resource::Base class" do
        resource = @site.resources.first
        assert_equal "Ruby return value! ", resource.heres_a_method
        assert_equal "Ruby return value! wee!", resource.heres_a_method("wee!")
      end

      should "augment the Drops::ResourceDrop class" do
        resource = @site.collections.pages.resources.find do |page|
          page.relative_path.to_s == "top-level-page.md"
        end

        assert_includes resource.output, "Test extension: Liquid return value"
      end
    end

    context "summary extensions" do
      setup do
        @site = resources_site
        @site.read

        @resource = @site.collections.pages.resources.find do |page|
          page.relative_path.to_s == "top-level-page.md"
        end
      end

      should "work in a Ruby template" do
        assert_equal "That's **great**!", @resource.summary

        @resource.singleton_class.include TestingSummaryService::RubyResource

        assert_equal "SUMMARY! That's **gr DONE", @resource.summary
      end

      should "work in a Liquid template" do
        @resource.singleton_class.include TestingSummaryService::RubyResource
        @site.render

        assert_includes @resource.output, "Summary: :SUMMARY! That’s **gr DONE:"
      end
    end
  end
end
