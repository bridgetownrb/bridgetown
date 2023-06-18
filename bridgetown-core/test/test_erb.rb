# frozen_string_literal: true

require "helper"

class TestERB < BridgetownUnitTest
  def setup
    @site = fixture_site
    @process_output = capture_output { @site.process }
    @erb_page = @site.resources.find { |p| p.data[:title] == "I'm an ERB Page" }
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

  context "capturing inside of component templates" do
    should "not leak into main output" do
      refute_includes @erb_page.output, "## You should not see this captured content."
    end
  end

  context "Rails-style extensions" do
    should "issue a warning" do
      assert_includes @process_output, "Uh oh! You're using a Rails-style filename extension in:"
      assert_includes @process_output, "rails-style.html.erb"
    end
  end

  # rubocop:disable Layout/TrailingWhitespace
  context "Declarative Shadow DOM" do
    should "render via helpers" do
      assert_includes @erb_page.output, <<~HTML
        <dsd-component>
          <template shadowrootmode="open">
            <slot></slot>
            <style>:host {
          display: block;
        }</style>
        </template>  
          <p>Default slot content.</p>
        
        </dsd-component>
      HTML
    end
  end
  # rubocop:enable Layout/TrailingWhitespace
end
