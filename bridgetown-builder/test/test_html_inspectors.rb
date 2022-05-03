# frozen_string_literal: true

require "helper"

Bridgetown::Builder # trigger autoload

class TestHtmlInspectors < BridgetownUnitTest
  include Bridgetown::Builders::DSL::Hooks
  include Bridgetown::Builders::DSL::HtmlInspectors
  include Bridgetown::Builders::DSL::Resources

  def functions # stub to get hooks working
    @_test_functions ||= []
  end

  context "a resource after being transformed" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)

      inspect_html do |document|
        document.query_selector_all("h1").each do |heading|
          heading.content = heading.content.sub("World", "Universe")
          heading.add_class "universal"
        end
      end
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
        bypass_html_inspectors true
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
  end
end
