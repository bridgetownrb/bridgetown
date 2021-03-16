# frozen_string_literal: true

require_relative "./helper"

class TestDocumentation < Minitest::Test
  context "plugins page" do
    setup do
      page = site.collections.docs.resources.find { |doc| doc.relative_url == "/docs/plugins" }
      document_root nokogiri(page)
    end

    should "have a formatted JSON code example" do
      assert_select "div.language-json pre.highlight", <<~JSON
        "dependencies": {
          "random-js-package": "2.4.6",
          "my-plugin": "../my-plugin"
        }
      JSON
    end
  end
end
