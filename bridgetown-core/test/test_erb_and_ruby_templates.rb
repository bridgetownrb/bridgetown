# frozen_string_literal: true

require "helper"

class TestERBAndRubyTemplates < BridgetownUnitTest
  before do
    @site = fixture_site
    @process_output = capture_output { @site.process }
    @erb_page = @site.resources.find { |p| p.data[:title] == "I'm an ERB Page" }
  end

  describe "ERB page" do
    it "renders page vars" do
      assert_includes @erb_page.output, "One two three: 1230"
    end

    it "renders Liquid components" do
      assert_includes @erb_page.output, "<span id='include-param'>Liquid FTW!</span>"
    end

    it "provides full suite of Liquid filters" do
      assert_includes @erb_page.output, "Oats, peas, beans, and barley grow."
    end

    it "allows Markdown content via a helper" do
      assert_includes @erb_page.output, "<h2 id=\"im-a-header\">I’m a header!</h2>"
      assert_includes @erb_page.output, "<li>Yay!</li>"
      assert_includes @erb_page.output, "<li>Nifty!</li>"
    end

    it "allows capturing into a variable" do
      assert_includes @erb_page.output, "This is how capturing works!".reverse
    end

    it "should properly handle block expressions" do
      assert_includes @erb_page.output, "\n===\n+Value: value+\n---\n"
    end

    it "shouldn't escape expressions in <%== %>" do
      assert_includes @erb_page.output, "<em>This is an unescaped expression & it shouldn't be escaped</em>"
    end
  end

  describe "ERB layout" do
    it "renders layout vars" do
      assert_includes @erb_page.output, "Test? test"
      assert_includes @erb_page.output, "<h1>I&#39;m an ERB Page</h1>"

      assert_includes @erb_page.output, "<footer>#{@site.time} / #{Bridgetown::VERSION}</footer>"
    end

    it "renders partials" do
      assert_includes @erb_page.output, "A partial success? yes."
      assert_includes @erb_page.output, "A partial success? YES!!"
    end
  end

  describe "capturing inside of component templates" do
    it "should not leak into main output" do
      refute_includes @erb_page.output, "## You should not see this captured content."
    end
  end

  describe "Rails-style extensions" do
    it "should issue a warning" do
      assert_includes @process_output, "Uh oh! You're using a Rails-style filename extension in:"
      assert_includes @process_output, "rails-style.html.erb"
    end
  end

  # rubocop:disable Layout/TrailingWhitespace
  describe "Declarative Shadow DOM" do
    it "renders via helpers" do
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

  describe "Pure Ruby Template Layout" do
    let(:ruby_page) { @site.resources.find { |p| p.data.layout == :rubylayout }.output }

    it "renders and includes yielded page content" do
      expect(ruby_page) << "<h1>Boo</h1>\n<p>This is a post with Ruby front matter.</p>"
      expect(ruby_page) << "Custom var: 123"
    end
  end
end
