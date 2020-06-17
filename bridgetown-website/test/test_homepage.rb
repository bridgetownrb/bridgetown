# frozen_string_literal: true

require_relative "./helper"

class TestHomepage < Minitest::Test
  context "homepage" do
    setup do
      page = site.pages.find { |doc| doc.url == "/" }
      document_root page
    end

    should "exist" do
      assert_select "body"
    end
  end
end
