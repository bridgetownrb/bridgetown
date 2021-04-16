# frozen_string_literal: true

require "helper"

class TestERB < BridgetownUnitTest
  def setup
    @site = fixture_site
    @site.process
    @erb_page = @site.pages.find { |p| p[:title] == "I'm an ERB Page" }
  end

  context "ERB page" do
    should "render page vars" do
      assert_includes @erb_page.output, "One two three: 1230"
    end

    should "render Liquid components" do
      assert_includes @erb_page.output, "<span id='include-param'>Liquid FTW!</span>"
    end

    should "provide full suite of Liquid filters" do
      assert_includes @erb_page.output, "Oats, peas, beans, and barley grow."
    end

    should "allow Markdown content via a helper" do
      assert_includes @erb_page.output, "<h2 id=\"im-a-header\">I’m a header!</h2>"
      assert_includes @erb_page.output, "<li>Yay!</li>"
      assert_includes @erb_page.output, "<li>Nifty!</li>"
    end

    should "allow capturing into a variable" do
      assert_includes @erb_page.output, "This is how capturing works!".reverse
    end

    should "properly handle block expressions" do
      assert_includes @erb_page.output, "\n===\n+Value: value+\n---\n"
    end
  end

  context "ERB layout" do
    should "render layout vars" do
      assert_includes @erb_page.output, "Test? test"
      assert_includes @erb_page.output, "<h1>I&#39;m an ERB Page</h1>"

      assert_includes @erb_page.output, "<footer>#{@site.time} / #{Bridgetown::VERSION}</footer>"
    end

    should "render partials" do
      assert_includes @erb_page.output, "A partial success? yes."
      assert_includes @erb_page.output, "A partial success? YES!!"
    end
  end
end
