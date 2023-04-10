# frozen_string_literal: true

require "helper"
require "rouge"

class TestKramdown < BridgetownUnitTest
  def fixture_converter(config)
    site = fixture_site(
      Utils.deep_merge_hashes(
        {
          "markdown" => "kramdown",
        },
        config
      )
    )
    Bridgetown::Cache.clear
    site.find_converter_instance(
      Bridgetown::Converters::Markdown
    )
  end

  context "kramdown" do
    setup do
      @config = {
        "kramdown" => {
          "smart_quotes"            => "lsquo,rsquo,ldquo,rdquo",
          "entity_output"           => "as_char",
          "toc_levels"              => "1..6",
          "auto_ids"                => false,
          "footnote_nr"             => 1,
          "show_warnings"           => true,

          "syntax_highlighter"      => "rouge",
          "syntax_highlighter_opts" => {
            "bold_every" => 8,
            "css"        => :class,
            "css_class"  => "highlight",
            "formatter"  => ::Rouge::Formatters::HTMLLegacy,
            "foobar"     => "lipsum",
          },
        },
      }
      @kramdown_config_keys = @config["kramdown"].keys
      @syntax_highlighter_opts_config_keys =
        @config["kramdown"]["syntax_highlighter_opts"].keys

      @converter = fixture_converter(@config)
    end

    should "not break kramdown" do
      kramdown_doc = Kramdown::Document.new("# Some Header #", @config["kramdown"])
      assert_equal :class, kramdown_doc.options[:syntax_highlighter_opts][:css]
      assert_equal "lipsum", kramdown_doc.options[:syntax_highlighter_opts][:foobar]
    end

    should "run Kramdown" do
      assert_equal "<h1>Some Header</h1>", @converter.convert("# Some Header #").strip
    end

    should "render mark tags" do
      assert_equal "<p>This is <mark>highlighted</mark> like <mark>this.</mark></p>",
                   @converter.convert("This is ::highlighted:: like ==this.==").strip
    end

    should "should log kramdown warnings" do
      allow_any_instance_of(Kramdown::Document).to receive(:warnings).and_return(["foo"])
      expect(Bridgetown.logger).to receive(:warn).with("Kramdown warning:", "foo")
      @converter.convert("Something")
    end

    should "render fenced code blocks with syntax highlighting" do
      result = nokogiri_fragment(@converter.convert(<<~MARKDOWN))
        ~~~ruby
        puts "Hello World"
        ~~~
      MARKDOWN
      div_highlight = ">div.highlight"
      selector = "div.highlighter-rouge#{div_highlight}>pre.highlight>code"
      refute(result.css(selector).empty?, result.to_html)
    end

    context "when asked to convert smart quotes" do
      should "convert" do
        converter = fixture_converter(@config)
        assert_match(
          %r!<p>(&#8220;|“)Pit(&#8217;|’)hy(&#8221;|”)</p>!,
          converter.convert(%("Pit'hy")).strip
        )
      end

      should "support custom types" do
        override = {
          "highlighter" => nil,
          "kramdown"    => {
            "smart_quotes" => "lsaquo,rsaquo,laquo,raquo",
          },
        }
        converter = fixture_converter(Utils.deep_merge_hashes(@config, override))
        assert_match %r!<p>(&#171;|«)Pit(&#8250;|›)hy(&#187;|»)</p>!, \
                     converter.convert(%("Pit'hy")).strip
      end
    end
  end
end
