# frozen_string_literal: true

require_relative "./helper"

class TestNavbar < Minitest::Test
  context "top navbar" do
    setup do
      page = site.pages.find { |doc| doc.url == "/about/" }
      document_root nokogiri(page)
    end

    should "have a star link" do
      assert_select "nav .navbar-end a:nth-of-type(1)", "Star"
    end

    should "have a news link" do
      assert_select "nav .navbar-start a:nth-of-type(3)", "News"
    end
  end
end
