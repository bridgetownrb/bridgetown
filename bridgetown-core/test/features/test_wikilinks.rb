# frozen_string_literal: true

require "features/feature_helper"

# Wiki-style links should be converted to regular Markdown (and then anchor tags)
class TestWikilinks < BridgetownFeatureTest
  describe "wikilinks initializer" do
    it "converts wikilinks to Markdown" do
      create_directory "config"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          init :wikilinks
        end
      RUBY

      create_directory "_posts"
      create_page "_posts/link-all-things.md",
                  "This should render [[Additional Page|a page]] and [[Also This Page#section-title]] but \\[[Additional Page]] should remain plain.",
                  date: "2026-04-26"

      create_page "_posts/one-additional-page.md",
                  "Content",
                  title: "Additional Page",
                  date: "2026-04-25"
      create_page "also-page.md", "Content", title: "Also This Page"

      run_bridgetown "build"

      assert_file_contains "<p>This should render <a href=\"/2026/04/25/one-additional-page/\" class=\"wikilink\">a page</a> and <a href=\"/also-page/#section-title\" class=\"wikilink\">Also This Page</a> but [[Additional Page]] should remain plain.</p>\n",
                           "output/2026/04/26/link-all-things/index.html"
    end
  end
end
