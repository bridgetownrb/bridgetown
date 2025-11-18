# frozen_string_literal: true

require "helper"

class TestComponents < BridgetownUnitTest
  def refresh_zeitwerk
    components_loader = Zeitwerk::Registry.loaders.each.find do |loader|
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
    refresh_zeitwerk do
      Example.send(:remove_const, "OverrideComponent") if defined?(Example::OverrideComponent)
      @site = fixture_site({ level: "Level" })
    end

    @site.process
    @erb_page = @site.collections.pages.resources.find { |page| page.data.title == "I'm an ERB Page" }
  end

  describe "basic Ruby components" do
    it "renders" do
      expect(@erb_page.output) << "Here's the page title! <strong>I'm an ERB Page</strong>"
    end

    it "allows source components to override plugin components" do
      expect(@erb_page.output) << "Yay, it got overridden!"
    end
  end

  describe "Bridgetown::Component" do
    it "renders with captured block content" do
      # lots of funky whitespace from all the erb captures!
      spaces = "  "
      morespaces = "      "
      expect(@erb_page.output) << <<~HTML # rubocop:disable Bridgetown/InsecureHeredoc
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

    it "does not render if render? is false" do
      expect(@erb_page.output)
        .exclude?("NOPE")
        .exclude?("Canceled!")
    end

    it "handles same-file namespaced components" do
      expect(@erb_page.output) << "<card-section>blurb contents</card-section>"
    end

    it "handles nested renders" do
      levels = []
      4.times do |i|
        levels << "#{i + 1}: Level #{i + 1}"
      end

      assert_includes @erb_page.output, levels.join("\n")
      assert_includes @erb_page.output, "4: Level 4\n\n  <p><strong>Level 4!!</strong></p>"
    end
  end
end
