# frozen_string_literal: true

require "helper"

class TestTags < BridgetownUnitTest
  def setup
    FileUtils.mkdir_p("tmp")
  end

  # rubocop:disable Metrics/AbcSize
  def create_post(content, override = {}, converter_class = Bridgetown::Converters::Markdown)
    site = fixture_site({ "highlighter" => "rouge" }.merge(override))

    site.posts.docs.concat(PostReader.new(site).read_posts("")) if override["read_posts"]
    CollectionReader.new(site).read if override["read_collections"]
    site.read if override["read_all"]

    info = { filters: [Bridgetown::Filters], registers: { site: site } }
    @converter = site.converters.find { |c| c.class == converter_class }
    payload = { "highlighter_prefix" => @converter.highlighter_prefix,
                "highlighter_suffix" => @converter.highlighter_suffix, }

    @result = Liquid::Template.parse(content).render!(payload, info)
    @result = @converter.convert(@result)
  end
  # rubocop:enable Metrics/AbcSize

  def fill_post(code, override = {})
    content = <<~CONTENT
      ---
      title: This is a test
      ---

      This document has some highlighted code in it.

      {% highlight text %}
      #{code}
      {% endhighlight %}
      {% highlight text linenos %}
      #{code}
      {% endhighlight %}
    CONTENT
    create_post(content, override)
  end

  def highlight_block_with_opts(options_string)
    Bridgetown::Tags::HighlightBlock.parse(
      "highlight",
      options_string,
      Liquid::Tokenizer.new("test{% endhighlight %}\n"),
      Liquid::ParseContext.new
    )
  end

  context "language name" do
    should "match only the required set of chars" do
      r = Bridgetown::Tags::HighlightBlock::SYNTAX
      assert_match r, "ruby"
      assert_match r, "c#"
      assert_match r, "xml+cheetah"
      assert_match r, "x.y"
      assert_match r, "coffee-script"
      assert_match r, "shell_session"

      refute_match r, "blah^"

      assert_match r, "ruby key=val"
      assert_match r, "ruby a=b c=d"
    end
  end

  context "highlight tag" do
    should "set the no options with just a language name" do
      tag = highlight_block_with_opts("ruby ")
      assert_equal({}, tag.instance_variable_get(:@highlight_options))
    end

    should "set the linenos option as 'inline' if no linenos value" do
      tag = highlight_block_with_opts("ruby linenos ")
      assert_equal(
        { linenos: "inline" },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "set the linenos option to 'table' " \
           "if the linenos key is given the table value" do
      tag = highlight_block_with_opts("ruby linenos=table ")
      assert_equal(
        { linenos: "table" },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "recognize nowrap option with linenos set" do
      tag = highlight_block_with_opts("ruby linenos=table nowrap ")
      assert_equal(
        { linenos: "table", nowrap: true },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "recognize the cssclass option" do
      tag = highlight_block_with_opts("ruby linenos=table cssclass=hl ")
      assert_equal(
        { cssclass: "hl", linenos: "table" },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "recognize the hl_linenos option and its value" do
      tag = highlight_block_with_opts("ruby linenos=table cssclass=hl hl_linenos=3 ")
      assert_equal(
        { cssclass: "hl", linenos: "table", hl_linenos: "3" },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "recognize multiple values of hl_linenos" do
      tag = highlight_block_with_opts 'ruby linenos=table cssclass=hl hl_linenos="3 5 6" '
      assert_equal(
        { cssclass: "hl", linenos: "table", hl_linenos: %w(3 5 6) },
        tag.instance_variable_get(:@highlight_options)
      )
    end

    should "treat language name as case insensitive" do
      tag = highlight_block_with_opts("Ruby ")
      assert_equal(
        "ruby",
        tag.instance_variable_get(:@lang),
        "lexers should be case insensitive"
      )
    end
  end

  context "with the rouge highlighter" do
    context "post content has highlight tag" do
      setup do
        fill_post("test")
      end

      should "render markdown with rouge" do
        assert_match(
          %(<pre><code class="language-text" data-lang="text">test</code></pre>),
          @result
        )
      end

      should "render markdown with rouge with line numbers" do
        assert_match(
          %(<table class="rouge-table"><tbody>) +
            %(<tr><td class="gutter gl">) +
            %(<pre class="lineno">1\n</pre></td>) +
            %(<td class="code"><pre>test\n</pre></td></tr>) +
            %(</tbody></table>),
          @result
        )
      end
    end

    context "post content has raw tag" do
      setup do
        content = <<~CONTENT
          ---
          title: This is a test
          ---

          ```liquid
          {% raw %}
          {{ site.baseurl }}{% link _collection/name-of-document.md %}
          {% endraw %}
          ```
        CONTENT
        create_post(content)
      end

      should "render markdown with rouge" do
        assert_match(
          %(<div class="language-liquid highlighter-rouge">) +
            %(<div class="highlight"><pre class="highlight"><code>),
          @result
        )
      end
    end

    context "post content has highlight with file reference" do
      setup do
        fill_post("./bridgetown.gemspec")
      end

      should "not embed the file" do
        assert_match(
          '<pre><code class="language-text" data-lang="text">' \
          "./bridgetown.gemspec</code></pre>",
          @result
        )
      end
    end

    context "post content has highlight tag with UTF character" do
      setup do
        fill_post("Æ")
      end

      should "render markdown with pygments line handling" do
        assert_match(
          '<pre><code class="language-text" data-lang="text">Æ</code></pre>',
          @result
        )
      end
    end

    context "post content has highlight tag with preceding spaces & lines" do
      setup do
        fill_post <<~EOS


               [,1] [,2]
          [1,] FALSE TRUE
          [2,] FALSE TRUE
        EOS
      end

      should "only strip the preceding newlines" do
        assert_match(
          '<pre><code class="language-text" data-lang="text">     [,1] [,2]',
          @result
        )
      end
    end

    context "post content has highlight tag with " \
            "preceding spaces & lines in several places" do
      setup do
        fill_post <<~EOS


               [,1] [,2]


          [1,] FALSE TRUE
          [2,] FALSE TRUE


        EOS
      end

      should "only strip the newlines which precede and succeed the entire block" do
        assert_match(
          "<pre><code class=\"language-text\" data-lang=\"text\">     [,1] [,2]\n\n\n" \
          "[1,] FALSE TRUE\n[2,] FALSE TRUE</code></pre>",
          @result
        )
      end
    end

    context "post content has highlight tag with linenumbers" do
      setup do
        create_post <<~EOS
          ---
          title: This is a test
          ---

          This is not yet highlighted
          {% highlight php linenos %}
          test
          {% endhighlight %}

          This should not be highlighted, right?
        EOS
      end

      should "should stop highlighting at boundary with rouge" do
        expected = <<~EOS
          <p>This is not yet highlighted</p>\n
          <figure class="highlight"><pre><code class="language-php" data-lang="php"><table class="rouge-table"><tbody><tr><td class="gutter gl"><pre class="lineno">1
          </pre></td><td class="code"><pre><span class="n">test</span>\n</pre></td></tr></tbody></table></code></pre></figure>\n
          <p>This should not be highlighted, right?</p>
        EOS
        assert_match(expected, @result)
      end
    end

    context "post content has highlight tag with " \
            "preceding spaces & Windows-style newlines" do
      setup do
        fill_post "\r\n\r\n\r\n     [,1] [,2]"
      end

      should "only strip the preceding newlines" do
        assert_match(
          '<pre><code class="language-text" data-lang="text">     [,1] [,2]',
          @result
        )
      end
    end

    context "post content has highlight tag with only preceding spaces" do
      setup do
        fill_post <<~EOS
               [,1] [,2]
          [1,] FALSE TRUE
          [2,] FALSE TRUE
        EOS
      end

      should "only strip the preceding newlines" do
        assert_match(
          '<pre><code class="language-text" data-lang="text">     [,1] [,2]',
          @result
        )
      end
    end
  end

  context "simple post with markdown and pre tags" do
    setup do
      @content = <<~CONTENT
        ---
        title: Kramdown post with pre
        ---

        _FIGHT!_

        {% highlight ruby %}
        puts "3..2..1.."
        {% endhighlight %}

        *FINISH HIM*
      CONTENT
    end

    context "using Kramdown" do
      setup do
        create_post(@content, "markdown" => "kramdown")
      end

      should "parse correctly" do
        assert_match %r{<em>FIGHT!</em>}, @result
        assert_match %r!<em>FINISH HIM</em>!, @result
      end
    end
  end

  context "simple page with post linking" do
    setup do
      content = <<~CONTENT
        ---
        title: Post linking
        ---

        {% post_url 2008-11-21-complex %}
      CONTENT
      create_post(content,
                  "permalink"   => "pretty",
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_posts"  => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'complex' post from 2008-11-21" do
      assert_match %r!/2008/11/21/complex/!, @result
    end
  end

  context "simple page with post linking containing special characters" do
    setup do
      content = <<~CONTENT
        ---
        title: Post linking
        ---

        {% post_url 2016-11-26-special-chars-(+) %}
      CONTENT
      create_post(content,
                  "permalink"   => "/foo/:title:output_ext",
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_posts"  => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'special-chars' post from 2016-11-26" do
      assert_match %r!/foo/special-chars-\(\+\).html!, @result
    end
  end

  context "simple page with nested post linking" do
    setup do
      content = <<~CONTENT
        ---
        title: Post linking
        ---

        - 1 {% post_url 2008-11-21-complex %}
        - 2 {% post_url /2008-11-21-complex %}
        - 3 {% post_url es/2008-11-21-nested %}
        - 4 {% post_url /es/2008-11-21-nested %}
      CONTENT
      create_post(content,
                  "permalink"   => "pretty",
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_posts"  => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'complex' post from 2008-11-21" do
      assert_match %r!1\s/2008/11/21/complex/!, @result
      assert_match %r!2\s/2008/11/21/complex/!, @result
    end

    should "have the URL to the 'nested' post from 2008-11-21" do
      assert_match %r!3\s/2008/11/21/nested/!, @result
      assert_match %r!4\s/2008/11/21/nested/!, @result
    end
  end

  context "simple page with nested post linking and path not used in `post_url`" do
    setup do
      content = <<~CONTENT
        ---
        title: Deprecated Post linking
        ---

        - 1 {% post_url 2008-11-21-nested %}
      CONTENT
      create_post(content,
                  "permalink"   => "pretty",
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_posts"  => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the url to the 'nested' post from 2008-11-21" do
      assert_match %r!1\s/2008/11/21/nested/!, @result
    end

    should "throw a deprecation warning" do
      deprecation_warning = "       Deprecation: A call to "\
        "'{% post_url 2008-11-21-nested %}' did not match a post using the new matching "\
        "method of checking name (path-date-slug) equality. Please make sure that you "\
        "change this tag to match the post's name exactly."
      assert_includes Bridgetown.logger.messages, deprecation_warning
    end
  end

  context "simple page with invalid post name linking" do
    should "cause an error" do
      content = <<~CONTENT
        ---
        title: Invalid post name linking
        ---

        {% post_url abc2008-11-21-complex %}
      CONTENT

      assert_raises Bridgetown::Errors::PostURLError do
        create_post(content,
                    "permalink"   => "pretty",
                    "source"      => source_dir,
                    "destination" => dest_dir,
                    "read_posts"  => true)
      end
    end

    should "cause an error with a bad date" do
      content = <<~CONTENT
        ---
        title: Invalid post name linking
        ---

        {% post_url 2008-42-21-complex %}
      CONTENT

      assert_raises Bridgetown::Errors::InvalidDateError do
        create_post(content,
                    "permalink"   => "pretty",
                    "source"      => source_dir,
                    "destination" => dest_dir,
                    "read_posts"  => true)
      end
    end
  end

  context "simple page with linking to a page" do
    setup do
      content = <<~CONTENT
        ---
        title: linking
        ---

        {% link contacts.html %}
        {% link info.md %}
        {% link /css/screen.css %}
      CONTENT
      create_post(content,
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_all"    => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'contacts' item" do
      assert_match(%r!/contacts\.html!, @result)
    end

    should "have the URL to the 'info' item" do
      assert_match(%r!/info\.html!, @result)
    end

    should "have the URL to the 'screen.css' item" do
      assert_match(%r!/css/screen\.css!, @result)
    end
  end

  context "simple page with dynamic linking to a page" do
    setup do
      content = <<~CONTENT
        ---
        title: linking
        ---

        {% assign contacts_filename = 'contacts' %}
        {% assign contacts_ext = 'html' %}
        {% link {{contacts_filename}}.{{contacts_ext}} %}
        {% assign info_path = 'info.md' %}
        {% link {{\ info_path\ }} %}
        {% assign screen_css_path = '/css' %}
        {% link {{ screen_css_path }}/screen.css %}
      CONTENT
      create_post(content,
                  "source"      => source_dir,
                  "destination" => dest_dir,
                  "read_all"    => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'contacts' item" do
      assert_match(%r!/contacts\.html!, @result)
    end

    should "have the URL to the 'info' item" do
      assert_match(%r!/info\.html!, @result)
    end

    should "have the URL to the 'screen.css' item" do
      assert_match(%r!/css/screen\.css!, @result)
    end
  end

  context "simple page with linking" do
    setup do
      content = <<~CONTENT
        ---
        title: linking
        ---

        {% link _methods/yaml_with_dots.md %}
      CONTENT
      create_post(content,
                  "source"           => source_dir,
                  "destination"      => dest_dir,
                  "collections"      => { "methods" => { "output" => true } },
                  "read_collections" => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'yaml_with_dots' item" do
      assert_match(%r!/methods/yaml_with_dots\.html!, @result)
    end
  end

  context "simple page with dynamic linking" do
    setup do
      content = <<~CONTENT
        ---
        title: linking
        ---

        {% assign yaml_with_dots_path = '_methods/yaml_with_dots.md' %}
        {% link {{yaml_with_dots_path}} %}
      CONTENT
      create_post(content,
                  "source"           => source_dir,
                  "destination"      => dest_dir,
                  "collections"      => { "methods" => { "output" => true } },
                  "read_collections" => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'yaml_with_dots' item" do
      assert_match(%r!/methods/yaml_with_dots\.html!, @result)
    end
  end

  context "simple page with nested linking" do
    setup do
      content = <<~CONTENT
        ---
        title: linking
        ---

        - 1 {% link _methods/sanitized_path.md %}
        - 2 {% link _methods/site/generate.md %}
      CONTENT
      create_post(content,
                  "source"           => source_dir,
                  "destination"      => dest_dir,
                  "collections"      => { "methods" => { "output" => true } },
                  "read_collections" => true)
    end

    should "not cause an error" do
      refute_match(%r!markdown\-html\-error!, @result)
    end

    should "have the URL to the 'sanitized_path' item" do
      assert_match %r!1\s/methods/sanitized_path\.html!, @result
    end

    should "have the URL to the 'site/generate' item" do
      assert_match %r!2\s/methods/site/generate\.html!, @result
    end
  end

  context "simple page with invalid linking" do
    should "cause an error" do
      content = <<~CONTENT
        ---
        title: Invalid linking
        ---

        {% link non-existent-collection-item %}
      CONTENT

      assert_raises ArgumentError do
        create_post(content,
                    "source"           => source_dir,
                    "destination"      => dest_dir,
                    "collections"      => { "methods" => { "output" => true } },
                    "read_collections" => true)
      end
    end
  end

  context "simple page with invalid dynamic linking" do
    should "cause an error" do
      content = <<~CONTENT
        ---
        title: Invalid linking
        ---

        {% assign non_existent_path = 'non-existent-collection-item' %}
        {% link {{\ non_existent_path\ }} %}
      CONTENT

      assert_raises ArgumentError do
        create_post(content,
                    "source"           => source_dir,
                    "destination"      => dest_dir,
                    "collections"      => { "methods" => { "output" => true } },
                    "read_collections" => true)
      end
    end
  end

  context "rendercontent tag" do
    context "with one parameter" do
      setup do
        content = <<~CONTENT
          ---
          title: Tag parameters
          ---

          {% rendercontent "test_component", param: "value" %}
            * I am Markdown
          {% endrendercontent %}
        CONTENT
        create_post(content,
                    "permalink"   => "pretty",
                    "source"      => source_dir,
                    "destination" => dest_dir,
                    "read_posts"  => true)
      end

      should "correctly output params and markdown content" do
        assert_match "<span id=\"include-param\">value</span>", @result
        assert_match "<main>\n<ul>\n  <li>I am Markdown</li>\n</ul>\n</main>", @result
        refute_match "---", @result
      end
    end
  end

  context "class_map tag" do
    context "renders without error" do
      setup do
        content = <<~CONTENT
          ---
          title: Class Map parameters
          ---

          {% assign small = true %}
          {% assign centered = "centered" %}
          {% assign filled = nil %}
          {% assign red-background = false %}

          <button class="{% class_map   is-small: small,  has-text-center:   centered, outlined:  !filled, red-bg: red-background, nodef: notdefined %}">Button</button>
        CONTENT
        create_post(content,
                    "permalink"   => "pretty",
                    "source"      => source_dir,
                    "destination" => dest_dir,
                    "read_posts"  => true)
      end

      should "correctly output names" do
        assert_match "<button class=\"is-small has-text-center outlined\">Button</button>", @result
      end
    end

    context "Returns an error if not properly formatted" do
      setup do
        content = <<~CONTENT
          ---
          title: Class Map parameters
          ---

          {% assign small = true %}
          {% assign centered = "centered" %}
          {% assign filled = nil %}
          {% assign red-background = false %}

          <button class="{% class_map is-small => small, has-text-center, centered, outlined: !filled, red-bg: red-background, nodef: notdefined %}">Button</button>
        CONTENT
        create_post(content,
                    "permalink"   => "pretty",
                    "source"      => source_dir,
                    "destination" => dest_dir,
                    "read_posts"  => true)
      end

      should "return an error due to improper formatting" do
        refute_match "<button class=\"is-small has-text-center outlined\">Button</button>", @result
        assert_match "<button class=\"invalid-class-map\">Button</button>", @result
      end
    end
  end
end
