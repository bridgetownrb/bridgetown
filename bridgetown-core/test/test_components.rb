# frozen_string_literal: true

require "helper"

class TestComponents < BridgetownUnitTest
  def refresh_zeitwork
    components_loader = Zeitwerk::Registry.loaders.find do |loader|
      loader.dirs.any? do |path|
        path.include?("_components")
      end
    end

    components_loader&.unload
    components_loader&.setup

    yield

    components_loader&.reload
  end

  def setup
    refresh_zeitwork do
      Example.send(:remove_const, "OverrideComponent") if defined?(Example::OverrideComponent)
      @site = fixture_site({ level: "Level" })
    end

    @site.process
    @erb_page = @site.collections.pages.resources.find { |page| page.data.title == "I'm an ERB Page" }
  end

  context "basic Ruby components" do
    should "should render" do
      assert_includes @erb_page.output, "Here's the page title! <strong>I'm an ERB Page</strong>"
    end

    should "allow source components to override plugin components" do
      assert_includes @erb_page.output, "Yay, it got overridden!"
    end
  end

  context "Bridgetown::Component" do
    should "should render with captured block content" do
      # lots of funky whitespace from all the erb captures!
      spaces = "  "
      morespaces = "      "
      assert_includes @erb_page.output, <<~HTML # rubocop:disable Bridgetown/HTMLEscapedHeredoc
        <app-card>
          <header>I&#39;M A CARD</header>
          <app-card-inner>
          #{spaces}
          <p>I'm the body of the card</p>

          #{morespaces}<img src="test.jpg" />

          #{spaces}NOTHING
          </app-card-inner>
          <footer>I&#39;m a footer</footer>
        </app-card>
      HTML
    end

    should "not render if render? is false" do
      refute_includes @erb_page.output, "NOPE"
      refute_includes @erb_page.output, "Canceled!"
    end

    should "handle nested renders" do
      levels = []
      4.times do |i|
        levels << "#{i + 1}: Level #{i + 1}"
      end

      assert_includes @erb_page.output, levels.join("\n")
      assert_includes @erb_page.output, "4: Level 4\n\n  <p><strong>Level 4!!</strong></p>"
    end
  end
end
