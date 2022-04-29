# frozen_string_literal: true

require "helper"

class TestSerbea < BridgetownUnitTest
  def setup
    @site = fixture_site
    @site.process
    @serb_page = @site.resources.find { |p| p.data[:title] == "I'm an Serbea Page" }
  end

  context "Serbea page" do
    should "render page vars" do
      assert_includes @serb_page.output, "One two three: 1230"
    end

    should "render Liquid components" do
      assert_includes @serb_page.output, "<span id='include-param'>Liquid FTW!</span>"
    end

    should "render Ruby/Serbea components" do
      assert_includes @serb_page.output, "1: Level 1"
      assert_includes @serb_page.output, "<p>** 4!!**</p>"
    end

    should "provide full suite of Liquid filters" do
      assert_includes @serb_page.output, "Oats, peas, beans, and barley grow."
    end

    should "allow Markdown content via a helper" do
      assert_includes @serb_page.output, "<h2 id=\"im-a-header\">I’m a header!</h2>"
      assert_includes @serb_page.output, "<li>Yay!</li>"
      assert_includes @serb_page.output, "<li>Nifty!</li>"
    end

    should "allow capturing into a variable" do
      assert_includes @serb_page.output, "This is how capturing works!".reverse
    end

    should "properly handle block expressions" do
      assert_includes @serb_page.output, "\n===\n+Value: value+\n---\n"
    end
  end

  context "Serbea layout" do
    should "render layout vars" do
      assert_includes @serb_page.output, "Test? test"
      assert_includes @serb_page.output, "<h1>I&#39;m an Serbea Page</h1>"

      assert_includes @serb_page.output, "<footer>#{@site.time} / #{Bridgetown::VERSION}</footer>"
    end

    should "render partials" do
      assert_includes @serb_page.output, "A partial success? yes."
      assert_includes @serb_page.output, "A partial success? YES!!"
    end
  end

  context "capturing inside of component templates" do
    should "not leak into main output" do
      refute_includes @serb_page.output, "## You should not see this captured content."
    end
  end
end
