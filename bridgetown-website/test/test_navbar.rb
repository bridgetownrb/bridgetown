# frozen_string_literal: true

require_relative "./helper"

class TestNavbar < Minitest::Test
  context "top navbar" do
    setup do
      @page = site.posts.docs.find { |doc| doc.url == "/feature/supercharge-your-bridgetown-site-with-ruby-front-matter/" }
      @dom = nokogiri(@page)
    end

    should "have a star link" do
      link = @dom.css("nav .navbar-menu a")[3]

      assert_equal "Star", link.text.strip
    end

    should "have a news link" do
      link = @dom.css("nav .navbar-menu a")[2]

      assert_equal "News", link.text.strip
    end
  end
end
