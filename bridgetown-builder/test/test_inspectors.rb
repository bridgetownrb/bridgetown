# frozen_string_literal: true

require "helper"

Bridgetown::Builder # trigger autoload

class TestInspectors < BridgetownUnitTest
  include Bridgetown::Builders::DSL::Hooks
  include Bridgetown::Builders::DSL::Inspectors
  include Bridgetown::Builders::DSL::Resources

  def functions # stub to get hooks working
    @_test_functions
  end

  attr_reader :site

  context "a resource after being transformed" do
    setup do
      @site = Site.new(site_configuration)
      @_test_functions = []

      inspect_html do |document|
        document.query_selector_all("h1").each do |heading|
          heading.content = heading.content.sub("World", "Universe")
          heading.add_class "universal"
        end
      end

      inspect_xml "atom" do |document, resource|
        title = document.query_selector("entry > title")
        title.content = title.content.upcase

        assert_equal ".atom", resource.extname
      end
    end

    teardown do
      @_html_inspectors = nil
      @_xml_inspectors = nil
    end

    should "allow manipulation via Nokogiri" do
      add_resource :posts, "html-inspectors.md" do
        title "I'm a Markdown post!"
        content <<~MARKDOWN
          # Hello World!
        MARKDOWN
      end

      resource = @site.collections.posts.resources.first
      assert_equal 1, @site.collections.posts.resources.length
      assert_equal "# Hello World!", resource.content.strip
      resource.transform!
      assert_equal %(<html><head></head><body><h1 id="hello-world" class="universal">Hello Universe!</h1>\n</body></html>),
                   resource.output.strip
    end

    should "bypass inspectors with special front matter variable" do
      add_resource :posts, "html-inspectors-bypass.md" do
        title "I'm a Markdown post!"
        bypass_inspectors true
        content <<~MARKDOWN
          # Hello World!
        MARKDOWN
      end

      resource = @site.collections.posts.resources.first
      assert_equal 1, @site.collections.posts.resources.length
      assert_equal "# Hello World!", resource.content.strip
      resource.transform!
      refute_equal %(<html><head></head><body><h1 id="hello-world" class="universal">Hello Universe!</h1>\n</body></html>),
                   resource.output.strip
    end

    should "not mess up non-HTML resources" do
      add_resource :posts, "no-html-inspectors.json" do
        content <<~JSON
          { a: 1, b: "2" }
        JSON
      end

      resource = @site.collections.posts.resources.first
      assert_equal 1, @site.collections.posts.resources.length
      assert_equal %({ a: 1, b: "2" }), resource.content.strip
      resource.transform!
      assert_equal %({ a: 1, b: "2" }),
                   resource.output.strip
    end

    should "work with XML resources too" do
      add_resource :pages, "sample-feed.atom" do
        content <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <feed xmlns="http://www.w3.org/2005/Atom">

            <title>Example Feed</title>
            <link href="http://example.org/"/>
            <updated>2003-12-13T18:30:02Z</updated>
            <author>
              <name>John Doe</name>
            </author>
            <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>

            <entry>
              <title>Atom-Powered Robots Run Amok</title>
              <link href="http://example.org/2003/12/13/atom03"/>
              <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
              <updated>2003-12-13T18:30:02Z</updated>
              <summary>Some text.</summary>
            </entry>

          </feed>
        XML
      end

      resource = @site.collections.pages.resources.first
      assert_equal 1, @site.collections.pages.resources.length
      assert_includes resource.content, "<title>Atom-Powered Robots Run Amok</title>"
      resource.transform!
      assert_includes resource.output, "<title>ATOM-POWERED ROBOTS RUN AMOK</title>"
    end
  end

  context "a resource to transform using Nokolexbor" do
    setup do
      @site = Site.new(site_configuration({ "html_inspector_parser" => "nokolexbor" }))
      @_test_functions = []

      inspect_html do |document|
        document.query_selector_all("h1").each do |heading|
          heading.content = heading.content.sub("World", "Universe")
          heading.add_class "universal"
        end
      end

      inspect_xml "atom" do |document, resource|
        title = document.query_selector("entry > title")
        title.content = title.content.upcase

        assert_equal ".atom", resource.extname
      end
    end

    teardown do
      @_html_inspectors = nil
      @_xml_inspectors = nil
    end

    should "allow manipulation via Nokolexbor" do
      add_resource :posts, "html-inspectors.md" do
        title "I'm a Markdown post!"
        content <<~MARKDOWN
          # Hello World!
        MARKDOWN
      end

      resource = @site.collections.posts.resources.first
      assert_equal 1, @site.collections.posts.resources.length
      assert_equal "# Hello World!", resource.content.strip
      resource.transform!
      assert_equal %(<html><head></head><body><h1 id="hello-world" class="universal">Hello Universe!</h1>\n</body></html>),
                   resource.output.strip
    end
  end
end
