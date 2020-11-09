# frozen_string_literal: true

require "helper"

class TestExcerpt < BridgetownUnitTest
  def setup_post(file)
    Document.new(@site.in_source_dir(File.join("_posts", file)),
                 site: @site,
                 collection: @site.posts).tap(&:read)
  end

  def do_render(document)
    @site.layouts = {
      "default" => Layout.new(@site, source_dir("_layouts"), "simple.html"),
    }
    Bridgetown::Renderer.new(@site, document).run
  end

  context "With extraction disabled" do
    setup do
      clear_dest
      @site = fixture_site("excerpt_separator" => "")
      @post = setup_post("2013-07-22-post-excerpt-with-layout.markdown")
    end

    should "not be generated" do
      refute @post.generate_excerpt?
    end
  end

  context "An extracted excerpt" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2013-07-22-post-excerpt-with-layout.markdown")
      @excerpt = @post.data["excerpt"]
    end

    context "#include(string)" do
      setup do
        @excerpt.output = "Here is a fake output stub"
      end

      should "return true only if an excerpt output contains a specified string" do
        assert @excerpt.include?("fake output")
        refute @excerpt.include?("real output")
      end
    end

    context "#id" do
      should "contain the UID for the post" do
        assert_equal @excerpt.id, "#{@post.id}#excerpt"
      end
      should "return a string" do
        assert_same @post.id.class, String
      end
    end

    context "#type" do
      should "return the post's type" do
        assert_equal @excerpt.type, @post.type
      end
      should "return a symbol" do
        assert_same @excerpt.type.class, Symbol
      end
    end

    context "#to_s" do
      should "return rendered output" do
        assert_equal @excerpt.output, @excerpt.to_s
      end

      should "return its output if output present" do
        @excerpt.output = "Fake Output"
        assert_equal @excerpt.output, @excerpt.to_s
      end
    end

    context "#inspect" do
      should "contain the excerpt id as a shorthand string identifier" do
        assert_equal @excerpt.inspect, "<#{@excerpt.class} id=#{@excerpt.id}>"
      end

      should "return a string" do
        assert_same @post.id.class, String
      end
    end

    context "#relative_path" do
      should "return its document's relative path with '/#excerpt' appended" do
        assert_equal "#{@excerpt.doc.relative_path}/#excerpt",
                     @excerpt.relative_path
        assert_equal "_posts/2013-07-22-post-excerpt-with-layout.markdown/#excerpt",
                     @excerpt.relative_path
      end
    end

    context "#to_liquid" do
      should "contain the proper page data to mimic the post liquid" do
        assert_equal "Post Excerpt with Layout", @excerpt.to_liquid["title"]
        url = "/bar/baz/z-category/mixedcase/2013/07/22/post-excerpt-with-layout.html"
        assert_equal url, @excerpt.to_liquid["url"]
        assert_equal Time.parse("2013-07-22"), @excerpt.to_liquid["date"]
        assert_equal %w(bar baz z_category MixedCase), @excerpt.to_liquid["categories"]
        assert_equal %w(first second third bridgetownrb.com), @excerpt.to_liquid["tags"]
        assert_equal "_posts/2013-07-22-post-excerpt-with-layout.markdown/#excerpt",
                     @excerpt.to_liquid["path"]
      end
    end

    context "#content" do
      context "before render" do
        should "be the first paragraph of the page" do
          expected = "First paragraph with [link ref][link].\n\n[link]: "\
                     "https://bridgetownrb.com/"
          assert_equal expected, @excerpt.content
        end

        should "contain any refs at the bottom of the page" do
          assert @excerpt.content.include?("[link]: https://bridgetownrb.com/")
        end
      end

      context "after render" do
        setup do
          @rendered_post = @post.dup
          do_render(@rendered_post)
          @extracted_excerpt = @rendered_post.data["excerpt"]
        end

        should "be the first paragraph of the page" do
          expected = "<p>First paragraph with <a href=\"https://bridgetownrb.com/\">link "\
                     "ref</a>.</p>\n\n"
          assert_equal expected, @extracted_excerpt.output
        end

        should "link properly" do
          assert @extracted_excerpt.content.include?("https://bridgetownrb.com/")
        end
      end

      context "with indented link references" do
        setup do
          @post = setup_post("2016-08-16-indented-link-references.markdown")
          @excerpt = @post.excerpt
        end

        should "contain all refs at the bottom of the page" do
          (0..3).each do |i|
            assert_match "[link_#{i}]: www.example.com/#{i}", @excerpt.content
          end
        end

        should "ignore indented code" do
          refute_match "[fakelink]:", @excerpt.content
        end

        should "render links properly" do
          @rendered_post = @post.dup
          do_render(@rendered_post)
          output = @rendered_post.data["excerpt"].output
          (0..3).each do |i|
            assert_includes output, "<a href=\"www.example.com/#{i}\">"
          end
        end
      end
    end
  end

  context "A whole-post excerpt" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2008-02-02-published.markdown")
      @excerpt = @post.data["excerpt"]
    end

    should "be generated" do
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end

    context "#content" do
      should "match the post content" do
        assert_equal @post.content, @excerpt.content
      end
    end
  end

  context "An excerpt with non-closed but valid Liquid block tag" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-01-28-open-liquid-block-excerpt.markdown")
      @excerpt = @post.data["excerpt"]

      head = @post.content.split("\n\n")[0]

      assert_includes @post.content, "{%\n  highlight\n"
      assert_includes @post.content, "{% raw"
      refute_includes head, "{% endraw %}"
      refute_includes head, "{% endhighlight %}"
    end

    should "be appended to as necessary and generated" do
      assert_includes @excerpt.content, "{% endraw %}"
      assert_includes @excerpt.content, "{% endhighlight %}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end

  context "An excerpt with valid closed Liquid block tag" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-01-28-closed-liquid-block-excerpt.markdown")
      @excerpt = @post.data["excerpt"]

      head = @post.content.split("\n\n")[0]

      assert_includes @post.content, "{%\n  highlight\n"
      assert_includes @post.content, "{% raw"
      assert_includes head, "{%\n  endraw\n%}"
      assert_includes head, "{%\n  endhighlight\n%}"
    end

    should "not be appended to but generated as is" do
      assert_includes @excerpt.content, "{%\n  endraw\n%}"
      assert_includes @excerpt.content, "{%\n  endhighlight\n%}"
      refute_includes @excerpt.content, "{%\n  endraw\n%}\n\n{% endraw %}"
      refute_includes @excerpt.content, "{%\n  endhighlight\n%}\n\n{% endhighlight %}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end

  context "An excerpt with non-closed but valid Liquid block tag with whitespace control" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-05-15-open-liquid-block-excerpt-whitespace-control.md")
      @excerpt = @post.data["excerpt"]

      assert_includes @post.content, "{%- for"
      refute_includes @post.content.split("\n\n")[0], "{%- endfor -%}"
    end

    should "be appended to as necessary and generated" do
      assert_includes @excerpt.content, "{% endfor %}"
      refute_includes @excerpt.content, "{% endfor %}\n\n{% endfor %}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end

  context "An excerpt with valid closed Liquid block tag with whitespace control" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-05-15-closed-liquid-block-excerpt-whitespace-control.md")
      @excerpt = @post.data["excerpt"]

      assert_includes @post.content, "{%- for"
      assert_includes @post.content.split("\n\n")[0], "{%- endfor -%}"
    end

    should "not be appended to but generated as is" do
      assert_includes @excerpt.content, "{%- endfor -%}"
      refute_includes @excerpt.content, "{% endfor %}\n\n{% endfor %}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end

  context "An excerpt with valid Liquid variable with whitespace control" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-05-15-excerpt-whitespace-control-variable.md")
      @excerpt = @post.data["excerpt"]

      assert_includes @post.content, "{%- assign"
    end

    should "not be appended to but generated as is" do
      assert_includes @excerpt.content, "{{- xyzzy -}}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end

  context "An excerpt with Liquid tags" do
    setup do
      clear_dest
      @site = fixture_site
      @post = setup_post("2018-11-15-excerpt-liquid-block.md")
      @excerpt = @post.data["excerpt"]

      assert_includes @post.content.split("\n\n")[0].strip, "{% continue %}"
      assert_equal true, Bridgetown::DoNothingBlock.ancestors.include?(Liquid::Block)
      assert_equal false, Bridgetown::DoNothingOther.ancestors.include?(Liquid::Block)
      assert_match "Bridgetown::DoNothingBlock", Liquid::Template.tags["do_nothing"].name
      assert_match "Bridgetown::DoNothingOther", Liquid::Template.tags["do_nothing_other"].name
    end

    should "close open block tags, including custom tags, and ignore others" do
      assert_includes @excerpt.content, "{% endcase %}"
      assert_includes @excerpt.content, "{% endif %}"
      assert_includes @excerpt.content, "{% endfor %}"
      assert_includes @excerpt.content, "{% endunless %}"
      assert_includes @excerpt.content, "{% enddo_nothing %}"
      refute_includes @excerpt.content, "{% enddo_nothing_other %}"
      assert_equal true, @excerpt.is_a?(Bridgetown::Excerpt)
    end
  end
end
