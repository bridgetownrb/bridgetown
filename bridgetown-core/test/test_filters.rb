# frozen_string_literal: true

require "helper"

class TestFilters < BridgetownUnitTest
  class BridgetownFilter
    include Bridgetown::Filters

    attr_accessor :site, :context

    def initialize(opts)
      @site = Bridgetown::Site.new(opts)
      @context = Liquid::Context.new(@site.site_payload, {}, site: @site)
    end
  end

  class Value
    def initialize(value)
      @value = value
    end

    def to_s
      @value.respond_to?(:call) ? @value.call : @value.to_s
    end
  end

  def make_filter_mock(opts = {})
    BridgetownFilter.new(site_configuration(opts.merge("skip_config_files" => true)))
  end

  class SelectDummy
    def select; end
  end

  M = Struct.new(:message) do
    def to_liquid
      [message]
    end
  end

  T = Struct.new(:name) do
    def to_liquid
      {
        "name" => name,
        :v     => 1,
        :thing => M.new({ kay: "jewelers" }),
        :stuff => true,
      }
    end
  end

  describe "filters" do
    before do
      @sample_time = Time.utc(2013, 3, 27, 11, 22, 33)
      @filter = make_filter_mock(
        "timezone"               => "UTC",
        "url"                    => "http://example.com",
        "base_path"              => "/base",
        "dont_show_posts_before" => @sample_time
      )
      @sample_date = Date.parse("2013-03-02")
      @time_as_string = "September 11, 2001 12:46:30 -0000"
      @date_as_string = "1995-12-21"
      @time_as_numeric = 1_399_680_607
      @integer_as_string = "142857"
      @array_of_objects = [
        { "color" => "teal", "size" => "large"  },
        { "color" => "red",  "size" => "large"  },
        { "color" => "red",  "size" => "medium" },
        { "color" => "blue", "size" => "medium" },
      ]
    end

    it "markdownifies with simple string" do
      assert_equal(
        "<p>something <strong>really</strong> simple</p>\n",
        @filter.markdownify("something **really** simple")
      )
    end

    it "markdownifies with a number" do
      assert_equal(
        "<p>404</p>\n",
        @filter.markdownify(404)
      )
    end

    describe "smartify filter" do
      it "converts quotes and typographic characters" do
        assert_equal(
          "SmartyPants is *not* Markdown",
          @filter.smartify("SmartyPants is *not* Markdown")
        )
        assert_equal(
          "“This filter’s test…”",
          @filter.smartify(%q{"This filter's test..."})
        )
      end

      it "converts not convert markdown to block HTML elements" do
        assert_equal(
          "#hashtag", # NOT "<h1>hashtag</h1>"
          @filter.smartify("#hashtag")
        )
      end

      it "escapes special characters when configured to do so" do
        kramdown = make_filter_mock(kramdown: { entity_output: :symbolic })
        assert_equal(
          "&ldquo;This filter&rsquo;s test&hellip;&rdquo;",
          kramdown.smartify(%q{"This filter's test..."})
        )
      end

      it "converts HTML entities to unicode characters" do
        assert_equal "’", @filter.smartify("&rsquo;")
        assert_equal "“", @filter.smartify("&ldquo;")
      end

      it "converts multiple lines" do
        assert_equal "…\n…", @filter.smartify("...\n...")
      end

      it "allows raw HTML passthrough" do
        assert_equal(
          "Span HTML is <em>not</em> escaped",
          @filter.smartify("Span HTML is <em>not</em> escaped")
        )
        assert_equal(
          "<div>Block HTML is not escaped</div>",
          @filter.smartify("<div>Block HTML is not escaped</div>")
        )
      end

      it "escapes special characters" do
        assert_equal "3 &lt; 4", @filter.smartify("3 < 4")
        assert_equal "5 &gt; 4", @filter.smartify("5 > 4")
        assert_equal "This &amp; that", @filter.smartify("This & that")
      end

      it "converts a number to a string" do
        assert_equal(
          "404",
          @filter.smartify(404)
        )
      end

      it "does not output any warnings" do
        assert_empty(
          capture_output { @filter.smartify("Test") }
        )
      end
    end

    it "converts array to sentence string with no args" do
      assert_equal "", @filter.array_to_sentence_string([])
    end

    it "converts array to sentence string with one arg" do
      assert_equal "1", @filter.array_to_sentence_string([1])
      assert_equal "chunky", @filter.array_to_sentence_string(["chunky"])
    end

    it "converts array to sentence string with two args" do
      assert_equal "1 and 2", @filter.array_to_sentence_string([1, 2])
      assert_equal "chunky and bacon", @filter.array_to_sentence_string(%w(chunky bacon))
    end

    it "converts array to sentence string with multiple args" do
      assert_equal "1, 2, 3, and 4", @filter.array_to_sentence_string([1, 2, 3, 4])
      assert_equal(
        "chunky, bacon, bits, and pieces",
        @filter.array_to_sentence_string(%w(chunky bacon bits pieces))
      )
    end

    it "converts array to sentence string with different connector" do
      assert_equal "1 or 2", @filter.array_to_sentence_string([1, 2], "or")
      assert_equal "1, 2, 3, or 4", @filter.array_to_sentence_string([1, 2, 3, 4], "or")
    end

    it "numbers_of_words filter" do
      assert_equal 7, @filter.number_of_words("These aren't the droids you're looking for.")
    end

    it "readings_time filter" do
      assert_equal 3, @filter.reading_time("word " * 551)

      new_wpm_filter = make_filter_mock(
        "reading_time_wpm" => 300
      )

      assert_equal 2, new_wpm_filter.reading_time("word " * 551)
      assert_equal 1.84, new_wpm_filter.reading_time("word " * 551, 2)
    end

    describe "normalize_whitespace filter" do
      it "replaces newlines with a space" do
        assert_equal "a b", @filter.normalize_whitespace("a\nb")
        assert_equal "a b", @filter.normalize_whitespace("a\n\nb")
      end

      it "replaces tabs with a space" do
        assert_equal "a b", @filter.normalize_whitespace("a\tb")
        assert_equal "a b", @filter.normalize_whitespace("a\t\tb")
      end

      it "replaces multiple spaces with a single space" do
        assert_equal "a b", @filter.normalize_whitespace("a  b")
        assert_equal "a b", @filter.normalize_whitespace("a\t\nb")
        assert_equal "a b", @filter.normalize_whitespace("a \t \n\nb")
      end

      it "strips whitespace from beginning and end of string" do
        assert_equal "a", @filter.normalize_whitespace("a ")
        assert_equal "a", @filter.normalize_whitespace(" a")
        assert_equal "a", @filter.normalize_whitespace(" a ")
      end
    end

    describe "date filters" do
      describe "with Time object" do
        it "formats a date with short format" do
          assert_equal "27 Mar 2013", @filter.date_to_string(@sample_time)
        end

        it "formats a date with long format" do
          assert_equal "27 March 2013", @filter.date_to_long_string(@sample_time)
        end

        it "formats a date with ordinal, US format" do
          assert_equal "Mar 27th, 2013",
                       @filter.date_to_string(@sample_time, "ordinal", "US")
        end

        it "formats a date with long, ordinal format" do
          assert_equal "27th March 2013",
                       @filter.date_to_long_string(@sample_time, "ordinal")
        end

        it "formats a time with xmlschema" do
          assert_equal(
            "2013-03-27T11:22:33+00:00",
            @filter.date_to_xmlschema(@sample_time)
          )
        end

        it "formats a time according to RFC-822" do
          assert_equal(
            "Wed, 27 Mar 2013 11:22:33 +0000",
            @filter.date_to_rfc822(@sample_time)
          )
        end

        it "does not modify a time in-place when using filters" do
          t = Time.new(2004, 9, 15, 0, 2, 37, "+01:00")
          assert_equal 3600, t.utc_offset
          @filter.date_to_string(t)
          assert_equal 3600, t.utc_offset
        end
      end

      describe "with Date object" do
        it "formats a date with short format" do
          assert_equal "02 Mar 2013", @filter.date_to_string(@sample_date)
        end

        it "formats a date with long format" do
          assert_equal "02 March 2013", @filter.date_to_long_string(@sample_date)
        end

        it "formats a date with ordinal format" do
          assert_equal "2nd Mar 2013", @filter.date_to_string(@sample_date, "ordinal")
        end

        it "formats a date with ordinal, US, long format" do
          assert_equal "March 2nd, 2013",
                       @filter.date_to_long_string(@sample_date, "ordinal", "US")
        end

        it "formats a time with xmlschema" do
          assert_equal(
            "2013-03-02T00:00:00+00:00",
            @filter.date_to_xmlschema(@sample_date)
          )
        end

        it "formats a time according to RFC-822" do
          assert_equal(
            "Sat, 02 Mar 2013 00:00:00 +0000",
            @filter.date_to_rfc822(@sample_date)
          )
        end
      end

      describe "with String object" do
        it "formats a date with short format" do
          assert_equal "11 Sep 2001", @filter.date_to_string(@time_as_string)
        end

        it "formats a date with long format" do
          assert_equal "11 September 2001", @filter.date_to_long_string(@time_as_string)
        end

        it "formats a date with ordinal, US format" do
          assert_equal "Sep 11th, 2001",
                       @filter.date_to_string(@time_as_string, "ordinal", "US")
        end

        it "formats a date with ordinal long format" do
          assert_equal "11th September 2001",
                       @filter.date_to_long_string(@time_as_string, "ordinal", "UK")
        end

        it "formats a time with xmlschema" do
          assert_equal(
            "2001-09-11T12:46:30+00:00",
            @filter.date_to_xmlschema(@time_as_string)
          )
        end

        it "formats a time according to RFC-822" do
          assert_equal(
            "Tue, 11 Sep 2001 12:46:30 +0000",
            @filter.date_to_rfc822(@time_as_string)
          )
        end

        it "converts a String to Integer" do
          assert_equal(
            142_857,
            @filter.to_integer(@integer_as_string)
          )
        end
      end

      describe "with a Numeric object" do
        it "formats a date with short format" do
          assert_equal "10 May 2014", @filter.date_to_string(@time_as_numeric)
        end

        it "formats a date with long format" do
          assert_equal "10 May 2014", @filter.date_to_long_string(@time_as_numeric)
        end

        it "formats a date with ordinal, US format" do
          assert_equal "May 10th, 2014",
                       @filter.date_to_string(@time_as_numeric, "ordinal", "US")
        end

        it "formats a date with ordinal, long format" do
          assert_equal "10th May 2014",
                       @filter.date_to_long_string(@time_as_numeric, "ordinal")
        end

        it "formats a time with xmlschema" do
          assert_match(
            "2014-05-10T00:10:07",
            @filter.date_to_xmlschema(@time_as_numeric)
          )
        end

        it "formats a time according to RFC-822" do
          assert_equal(
            "Sat, 10 May 2014 00:10:07 +0000",
            @filter.date_to_rfc822(@time_as_numeric)
          )
        end
      end

      describe "without input" do
        it "returns input" do
          assert_nil(@filter.date_to_xmlschema(nil))
          assert_equal("", @filter.date_to_xmlschema(""))
        end
      end
    end

    describe "translation filters" do
      before do
        @filter.site.config.available_locales = I18n.available_locales = [:eo, :fr]
        @filter.site.config.default_locale = I18n.locale = :eo
      end

      describe "lookup" do
        it "translates error message with default locale" do
          assert_equal "ne estas nombro", @filter.t("errors.messages.not_a_number")
        end

        it "translates error message with french locale" do
          assert_equal "n'est pas un nombre", @filter.t("errors.messages.not_a_number", "locale:fr")
        end
      end

      describe "pluralization" do
        it "translates distance message with default locale" do
          assert_equal "ĉirkaŭ unu horo", @filter.t("datetime.distance_in_words.about_x_hours", "count:1")
        end

        it "translates pluralized distance message with default locale" do
          assert_equal "ĉirkaŭ 3 horoj", @filter.t("datetime.distance_in_words.about_x_hours", "count:3")
        end

        it "translates distance message with french locale" do
          assert_equal "environ une heure", @filter.t("datetime.distance_in_words.about_x_hours", "count:1, locale:fr")
        end

        it "translates pluralized distance message with french locale" do
          assert_equal "environ 3 heures", @filter.t("datetime.distance_in_words.about_x_hours", "locale:fr,  count:3")
        end
      end

      describe "defaults" do
        it "translates missing message with default locale" do
          assert_equal "foo", @filter.t("missing", "default:foo")
        end

        it "translates missing message with french locale" do
          assert_equal "foo", @filter.t("missing", "locale:fr, default:foo")
        end
      end

      describe "scope" do
        it "translates error message with default locale" do
          assert_equal "ne estas nombro", @filter.t("messages.not_a_number", "scope:errors")
        end

        it "translates error message with french locale" do
          assert_equal "n'est pas un nombre", @filter.t("messages.not_a_number", "locale:fr, scope:errors")
        end
      end

      describe "without input" do
        it "returns input" do
          assert_nil(@filter.t(nil))
          assert_equal("", @filter.t(""))
        end
      end
    end

    describe "localization filters" do
      before do
        @filter.site.config.available_locales = I18n.available_locales = [:eo, :fr]
        @filter.site.config.default_locale = I18n.locale = :eo
      end

      describe "with Time object" do
        it "formats a datetime with default format" do
          assert_equal "27 marto 2013 11:22:33", @filter.l(@sample_time)
        end

        it "formats a datetime with short format" do
          assert_equal "27 mar. 11:22", @filter.l(@sample_time, "short")
        end

        it "formats a datetime with short format in french locale" do
          assert_equal "27 mars 11h22", @filter.l(@sample_time, "short", "fr")
        end

        it "formats a datetime with default format in french locale" do
          assert_equal "27 mars 2013 11h 22min 33s", @filter.l(@sample_time, "fr")
        end
      end

      describe "with Date object" do
        it "formats a date with default format" do
          assert_equal "2013/03/02", @filter.l(@sample_date)
        end

        it "formats a date with short format" do
          assert_equal "2 mar.", @filter.l(@sample_date, "short")
        end

        it "formats a date with short format in french locale" do
          assert_equal "2 mars", @filter.l(@sample_date, "short", "fr")
        end

        it "formats a date with default format in french locale" do
          assert_equal "02/03/2013", @filter.l(@sample_date, "fr")
        end
      end

      describe "with String object" do
        describe "representing a time" do
          it "formats a datetime with default format" do
            assert_equal "11 septembro 2001 12:46:30", @filter.l(@time_as_string)
          end

          it "formats a datetime with short format" do
            assert_equal "11 sep. 12:46", @filter.l(@time_as_string, "short")
          end

          it "formats a datetime with short format in french locale" do
            assert_equal "11 sept. 12h46", @filter.l(@time_as_string, "short", "fr")
          end

          it "formats a datetime with default format in french locale" do
            assert_equal "11 septembre 2001 12h 46min 30s", @filter.l(@time_as_string, "fr")
          end
        end

        describe "representing a date" do
          it "formats a date with default format" do
            assert_equal "21 decembro 1995 00:00:00", @filter.l(@date_as_string)
          end

          it "formats a date with short format" do
            assert_equal "21 dec. 00:00", @filter.l(@date_as_string, "short")
          end

          it "formats a date with short format in french locale" do
            assert_equal "21 déc. 00h00", @filter.l(@date_as_string, "short", "fr")
          end

          it "formats a date with default format in french locale" do
            assert_equal "21 décembre 1995 00h 00min 00s", @filter.l(@date_as_string, "fr")
          end
        end
      end

      describe "with a Numeric object" do
        it "formats a datetime with default format" do
          assert_equal "10 majo 2014 00:10:07", @filter.l(@time_as_numeric)
        end

        it "formats a datetime with short format" do
          assert_equal "10 majo 00:10", @filter.l(@time_as_numeric, "short")
        end

        it "formats a datetime with short format in french locale" do
          assert_equal "10 mai 00h10", @filter.l(@time_as_numeric, "short", "fr")
        end

        it "formats a datetime with default format in french locale" do
          assert_equal "10 mai 2014 00h 10min 07s", @filter.l(@time_as_numeric, "fr")
        end
      end

      describe "without input" do
        it "returns input" do
          assert_nil(@filter.l(nil))
          assert_equal("", @filter.l(""))
        end
      end
    end

    it "escapes xml with ampersands" do
      assert_equal "AT&amp;T", @filter.xml_escape("AT&T")
      assert_equal(
        "&lt;code&gt;command &amp;lt;filename&amp;gt;&lt;/code&gt;",
        @filter.xml_escape("<code>command &lt;filename&gt;</code>")
      )
    end

    it "does not error when xml escaping nil" do
      assert_equal "", @filter.xml_escape(nil)
    end

    it "escapes space as plus" do
      assert_equal "my+things", @filter.cgi_escape("my things")
    end

    it "escapes special characters" do
      assert_equal "hey%21", @filter.cgi_escape("hey!")
    end

    it "escapes space as %20" do
      assert_equal "my%20things", @filter.uri_escape("my things")
    end

    it "allows reserver characters in URI" do
      assert_equal(
        "foo!*'();:@&=+$,/?#[]bar",
        @filter.uri_escape("foo!*'();:@&=+$,/?#[]bar")
      )
      assert_equal(
        "foo%20bar!*'();:@&=+$,/?#[]baz",
        @filter.uri_escape("foo bar!*'();:@&=+$,/?#[]baz")
      )
    end

    it "obfuscates email addresses" do
      assert_match(
        %r!>2:=E@iE6DEo6I2>A=6\]4@>!,
        @filter.obfuscate_link("test@example.com")
      )
    end

    it "obfuscates phone numbers" do
      assert_match(
        %r!E6=iZ`\\\\abc\\\\def!,
        @filter.obfuscate_link("+1-234-567", "tel")
      )
    end

    it "obfuscates sms targets" do
      assert_match(
        %r!D>DiU3@5Jlw6==@!,
        @filter.obfuscate_link("&body=Hello", "sms")
      )
    end

    describe "absolute_url filter" do
      it "produces an absolute URL from a page URL" do
        page_url = "/about/my_favorite_page/"
        assert_equal "http://example.com/base#{page_url}", @filter.absolute_url(page_url)
      end

      it "ensures the leading slash" do
        page_url = "about/my_favorite_page/"
        assert_equal "http://example.com/base/#{page_url}", @filter.absolute_url(page_url)
      end

      it "ensures the leading slash for the base_path" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "base"
        )
        assert_equal "http://example.com/base/#{page_url}", filter.absolute_url(page_url)
      end

      it "is ok with a blank but present 'url'" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock(
          "url"       => "",
          "base_path" => "base"
        )
        assert_equal "/base/#{page_url}", filter.absolute_url(page_url)
      end

      it "is ok with a nil 'url'" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock(
          "url"       => nil,
          "base_path" => "base"
        )
        assert_equal "/base/#{page_url}", filter.absolute_url(page_url)
      end

      it "is ok with a nil 'base_path'" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => nil
        )
        assert_equal "http://example.com/#{page_url}", filter.absolute_url(page_url)
      end

      it "does not prepend a forward slash if input is empty" do
        page_url = ""
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/base"
        )
        assert_equal "http://example.com/base", filter.absolute_url(page_url)
      end

      it "does not append a forward slash if input is '/'" do
        page_url = "/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/base"
        )
        assert_equal "http://example.com/base/", filter.absolute_url(page_url)
      end

      it "does not append a forward slash if input is '/' and nil 'base_path'" do
        page_url = "/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => nil
        )
        assert_equal "http://example.com/", filter.absolute_url(page_url)
      end

      it "does not append a forward slash if both input and base_path are simply '/'" do
        page_url = "/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/"
        )
        assert_equal "http://example.com/", filter.absolute_url(page_url)
      end

      it "normalizes international URLs" do
        page_url = ""
        filter = make_filter_mock(
          "url"       => "http://ümlaut.example.org/",
          "base_path" => nil
        )
        assert_equal "http://xn--mlaut-jva.example.org/", filter.absolute_url(page_url)
      end

      it "does not modify an absolute URL" do
        page_url = "http://example.com/"
        assert_equal "http://example.com/", @filter.absolute_url(page_url)
      end

      it "transforms the input URL to a string" do
        page_url = "/my-page.html"
        filter = make_filter_mock("url" => Value.new(proc { "http://example.org" }))
        assert_equal "http://example.org#{page_url}", filter.absolute_url(page_url)
      end

      it "does not raise a TypeError when passed a hash" do
        assert @filter.absolute_url("foo" => "bar")
      end

      describe "with a document" do
        before do
          @site = fixture_site(
            "url"         => "http://example.com",
            "base_path"   => "/base",
            "collections" => { methods: { output: true } }
          )
          @site.process
          @document = @site.collections["methods"].resources.detect do |d|
            d.relative_path.to_s == "_methods/configuration.md"
          end
        end

        it "makes a url" do
          expected = "http://example.com/base/methods/configuration/"
          assert_equal expected, @filter.absolute_url(@document)
        end
      end
    end

    describe "relative_url filter" do
      it "produces a relative URL from a page URL" do
        page_url = "/about/my_favorite_page/"
        assert_equal "/base#{page_url}", @filter.relative_url(page_url)
      end

      it "ensures the leading slash between base_path and input" do
        page_url = "about/my_favorite_page/"
        assert_equal "/base/#{page_url}", @filter.relative_url(page_url)
      end

      it "ensures the leading slash for the base_path" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock("base_path" => "base")
        assert_equal "/base/#{page_url}", filter.relative_url(page_url)
      end

      it "normalizes international URLs" do
        page_url = "错误.html"
        assert_equal "/base/%E9%94%99%E8%AF%AF.html", @filter.relative_url(page_url)
      end

      it "is ok with a nil 'base_path'" do
        page_url = "about/my_favorite_page/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => nil
        )
        assert_equal "/#{page_url}", filter.relative_url(page_url)
      end

      it "does not prepend a forward slash if input is empty" do
        page_url = ""
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/base"
        )
        assert_equal "/base", filter.relative_url(page_url)
      end

      it "does not prepend a forward slash if base_path ends with a single '/'" do
        page_url = "/css/main.css"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/base/"
        )
        assert_equal "/base/css/main.css", filter.relative_url(page_url)
      end

      it "does not return valid URI if base_path ends with multiple '/'" do
        page_url = "/css/main.css"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/base//"
        )
        refute_equal "/base/css/main.css", filter.relative_url(page_url)
      end

      it "does not prepend a forward slash if both input and base_path are simply '/'" do
        page_url = "/"
        filter = make_filter_mock(
          "url"       => "http://example.com",
          "base_path" => "/"
        )
        assert_equal "/", filter.relative_url(page_url)
      end

      it "does not return the url by reference" do
        filter = make_filter_mock(base_path: nil)
        page = GeneratedPage.new(filter.site, testing_dir("fixtures"), "", "front_matter.erb")
        assert_equal "/front_matter/", page.url
        url = filter.relative_url(page.url)
        url << "foo"
        assert_equal "/front_matter/", page.url
      end

      it "transforms protocol-relative url" do
        url = "//example.com/"
        assert_equal "/base//example.com/", @filter.relative_url(url)
      end

      it "does not modify an absolute url with scheme" do
        url = "file:///file.html"
        assert_equal url, @filter.relative_url(url)
      end

      it "does not normalize absolute international URLs" do
        url = "https://example.com/错误"
        assert_equal "https://example.com/错误", @filter.relative_url(url)
      end
    end

    describe "strip_index filter" do
      it "strips trailing /index.html" do
        assert_equal "/foo/", @filter.strip_index("/foo/index.html")
      end

      it "strips trailing /index.htm" do
        assert_equal "/foo/", @filter.strip_index("/foo/index.htm")
      end

      it "does not strip HTML in the middle of URLs" do
        assert_equal "/index.html/foo", @filter.strip_index("/index.html/foo")
      end

      it "does not raise an error on nil strings" do
        assert_nil @filter.strip_index(nil)
      end

      it "does not mangle other URLs" do
        assert_equal "/foo/", @filter.strip_index("/foo/")
      end
    end

    describe "jsonify filter" do
      it "converts hash to json" do
        assert_equal "{\"age\":18}", @filter.jsonify(age: 18)
      end

      it "converts array to json" do
        assert_equal "[1,2]", @filter.jsonify([1, 2])
        assert_equal(
          "[{\"name\":\"Jack\"},{\"name\":\"Smith\"}]",
          @filter.jsonify([{ name: "Jack" }, { name: "Smith" }])
        )
      end

      it "converts drop to json" do
        @filter.site.read
        expected = {
          "output"          => nil,
          "id"              => "repo://posts.collection/_posts/2008-02-02-published.markdown",
          "relative_url"    => "/base/publish_test/2008/02/02/published/",
          "taxonomies"      => {
            "category" => {
              "type"  => {
                "label"    => "category",
                "key"      => "categories",
                "metadata" => {
                  "title" => "Category",
                },
              },
              "terms" => [{
                "label" => "publish_test",
              }],
            },
            "tag"      => {
              "type"  => {
                "label"    => "tag",
                "key"      => "tags",
                "metadata" => {
                  "title" => "Tag",
                },
              },
              "terms" => [],
            },
          },
          "relative_path"   => "_posts/2008-02-02-published.markdown",
          "next"            => nil,
          "date"            => "2008-02-02 00:00:00 +0000",
          "summary"         => "This should be published.",
          "data"            => {
            "ruby3"           => "groovy",
            "layout"          => "default",
            "title"           => "Publish",
            "category"        => "publish_test",
            "categories"      => [
              "publish_test",
            ],
            "tags"            => [],
            "locale"          => "en",
            "date"            => "2008-02-02 00:00:00 +0000",
            "slug"            => "published",
            "template_engine" => "erb",
          },
          "absolute_url"    => "http://example.com/base/publish_test/2008/02/02/published/",
          "collection"      => "posts",
          "content"         => "This should be published.\n",
          "ruby3"           => "groovy",
          "layout"          => "default",
          "title"           => "Publish",
          "category"        => "publish_test",
          "categories"      => ["publish_test"],
          "tags"            => [],
          "locale"          => "en",
          "slug"            => "published",
          "template_engine" => "erb",
        }
        actual = JSON.parse(@filter.jsonify(@filter.site.resources_to_write.find do |post|
          post.data.title == "Publish" && post.data.slug == "published"
        end.to_liquid))

        actual.delete("path")
        actual.delete("heres_a_liquid_method") # could be added in by accident through a plugin
        prev = actual.delete("previous")
        refute_nil prev
        assert prev.is_a?(Hash), "doc.next should be an object"
        relations = actual.delete("relations")
        refute_nil relations
        all_locales = actual.delete("all_locales")
        assert all_locales.length == 1
        assert_equal expected, actual
      end

      it "converts drop with drops to json" do
        @filter.site.read
        actual = @filter.jsonify(@filter.site.to_liquid)
        expected = {
          "environment" => "test",
          "code_name"   => Bridgetown::CODE_NAME,
          "version"     => Bridgetown::VERSION,
        }
        assert_equal expected, JSON.parse(actual)["bridgetown"]
      end

      it "calls #to_liquid " do
        expected = [
          {
            "name"  => "Jeremiah",
            "v"     => 1,
            "thing" => [
              {
                "kay" => "jewelers",
              },
            ],
            "stuff" => true,
          },
          {
            "name"  => "Smathers",
            "v"     => 1,
            "thing" => [
              {
                "kay" => "jewelers",
              },
            ],
            "stuff" => true,
          },
        ]
        result = @filter.jsonify([T.new("Jeremiah"), T.new("Smathers")])
        assert_equal expected, JSON.parse(result)
      end

      it "handles hashes with all sorts of weird keys and values" do
        my_hash = { "posts" => Array.new(3) { |i| T.new(i) } }
        expected = {
          "posts" => [
            {
              "name"  => 0,
              "v"     => 1,
              "thing" => [
                {
                  "kay" => "jewelers",
                },
              ],
              "stuff" => true,
            },
            {
              "name"  => 1,
              "v"     => 1,
              "thing" => [
                {
                  "kay" => "jewelers",
                },
              ],
              "stuff" => true,
            },
            {
              "name"  => 2,
              "v"     => 1,
              "thing" => [
                {
                  "kay" => "jewelers",
                },
              ],
              "stuff" => true,
            },
          ],
        }
        result = @filter.jsonify(my_hash)
        assert_equal expected, JSON.parse(result)
      end
    end

    describe "group_by filter" do
      it "successfully groups array of pages" do
        @filter.site.process
        grouping = @filter.group_by(@filter.site.collections.pages.resources, "layout")
        grouping.each do |g|
          assert(
            ["default",
             "erblayout",
             "serblayout",
             "example/test_layout",
             "example/overridden_layout",
             "nil",
             "",].include?(g["name"]),
            "#{g["name"]} isn't a valid grouping."
          )
          case g["name"]
          when "default"
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for 'default' is not an Array."
            )
            assert_equal 5, g["items"].size
          when "nil"
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for 'nil' is not an Array."
            )
            assert_equal 2, g["items"].size
          when ""
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for '' is not an Array."
            )
            assert_equal 19, g["items"].size
          end
        end
      end

      it "includes the size of each grouping" do
        grouping = @filter.group_by(@filter.site.collections.pages.resources, "layout")
        grouping.each do |g|
          assert_equal(
            g["items"].size,
            g["size"],
            "The size property for '#{g["name"]}' doesn't match the size of the Array."
          )
        end
      end

      it "passes integers as is" do
        grouping = @filter.group_by([
          { "name" => "Allison", "year" => 2016 },
          { "name" => "Amy", "year" => 2016 },
          { "name" => "George", "year" => 2019 },
        ], "year")
        assert_equal "2016", grouping[0]["name"]
        assert_equal "2019", grouping[1]["name"]
      end
    end

    describe "where filter" do
      it "returns any input that is not an array" do
        assert_equal "some string", @filter.where("some string", "la", "le")
      end

      it "filters objects in a hash appropriately" do
        hash = { "a" => { "color"=>"red" }, "b" => { "color"=>"blue" } }
        assert_equal 1, @filter.where(hash, "color", "red").length
        assert_equal [{ "color"=>"red" }], @filter.where(hash, "color", "red")
      end

      it "filters objects appropriately" do
        assert_equal 2, @filter.where(@array_of_objects, "color", "red").length
      end

      it "filters objects with null properties appropriately" do
        array = [{}, { "color" => nil }, { "color" => "" }, { "color" => "text" }]
        assert_equal 2, @filter.where(array, "color", nil).length
      end

      it "filters objects with numerical properties appropriately" do
        array = [
          { "value" => "555" },
          { "value" => 555 },
          { "value" => 24.625 },
          { "value" => "24.625" },
        ]
        assert_equal 2, @filter.where(array, "value", 24.625).length
        assert_equal 2, @filter.where(array, "value", 555).length
      end

      it "filters array properties appropriately" do
        hash = {
          "a" => { "tags"=>%w(x y) },
          "b" => { "tags"=>["x"] },
          "c" => { "tags"=>%w(y z) },
        }
        assert_equal 2, @filter.where(hash, "tags", "x").length
      end

      it "filters array properties alongside string properties" do
        hash = {
          "a" => { "tags"=>%w(x y) },
          "b" => { "tags"=>"x" },
          "c" => { "tags"=>%w(y z) },
        }
        assert_equal 2, @filter.where(hash, "tags", "x").length
      end

      it "filters hash properties with null and empty values" do
        hash = {
          "a" => { "tags" => {} },
          "b" => { "tags" => "" },
          "c" => { "tags" => nil },
          "d" => { "tags" => ["x", nil] },
          "e" => { "tags" => [] },
          "f" => { "tags" => "xtra" },
        }

        assert_equal [{ "tags" => nil }], @filter.where(hash, "tags", nil)

        assert_equal(
          [{ "tags" => {} }, { "tags" => "" }, { "tags" => nil }, { "tags" => [] }],
          @filter.where(hash, "tags", "")
        )

        # `{{ hash | where: 'tags', empty }}`
        assert_equal(
          [{ "tags" => {} }, { "tags" => "" }, { "tags" => nil }, { "tags" => [] }],
          @filter.where(hash, "tags", Liquid::Expression::LITERALS["empty"])
        )

        # `{{ `hash | where: 'tags', blank }}`
        assert_equal(
          [{ "tags" => {} }, { "tags" => "" }, { "tags" => nil }, { "tags" => [] }],
          @filter.where(hash, "tags", Liquid::Expression::LITERALS["blank"])
        )
      end

      it "does not match substrings" do
        hash = {
          "a" => { "category"=>"bear" },
          "b" => { "category"=>"wolf" },
          "c" => { "category"=>%w(bear lion) },
        }
        assert_equal 0, @filter.where(hash, "category", "ear").length
      end

      it "stringifies during comparison for compatibility with liquid parsing" do
        hash = {
          "The Words" => { "rating" => 1.2, "featured" => false },
          "Limitless" => { "rating" => 9.2, "featured" => true },
          "Hustle"    => { "rating" => 4.7, "featured" => true },
        }

        results = @filter.where(hash, "featured", "true")
        assert_equal 2, results.length
        assert_equal 9.2, results[0]["rating"]
        assert_equal 4.7, results[1]["rating"]

        results = @filter.where(hash, "rating", 4.7)
        assert_equal 1, results.length
        assert_equal 4.7, results[0]["rating"]
      end

      it "always returns an array if the object responds to 'select'" do
        results = @filter.where(SelectDummy.new, "obj", "1 == 1")
        assert_equal [], results
      end
    end

    describe "where_exp filter" do
      it "returns any input that is not an array" do
        assert_equal "some string", @filter.where_exp("some string", "la", "le")
      end

      it "filters objects in a hash appropriately" do
        hash = { "a" => { "color"=>"red" }, "b" => { "color"=>"blue" } }
        assert_equal 1, @filter.where_exp(hash, "item", "item.color == 'red'").length
        assert_equal(
          [{ "color"=>"red" }],
          @filter.where_exp(hash, "item", "item.color == 'red'")
        )
      end

      it "filters objects appropriately" do
        assert_equal(
          2,
          @filter.where_exp(@array_of_objects, "item", "item.color == 'red'").length
        )
      end

      it "filters objects appropriately with 'or', 'and' operators" do
        assert_equal(
          [
            { "color" => "teal", "size" => "large"  },
            { "color" => "red",  "size" => "large"  },
            { "color" => "red",  "size" => "medium" },
          ],
          @filter.where_exp(
            @array_of_objects, "item", "item.color == 'red' or item.size == 'large'"
          )
        )

        assert_equal(
          [
            { "color" => "red", "size" => "large" },
          ],
          @filter.where_exp(
            @array_of_objects, "item", "item.color == 'red' and item.size == 'large'"
          )
        )
      end

      it "filters objects across multiple conditions" do
        sample = [
          { "color" => "teal", "size" => "large", "type" => "variable" },
          { "color" => "red",  "size" => "large", "type" => "fixed" },
          { "color" => "red",  "size" => "medium", "type" => "variable" },
          { "color" => "blue", "size" => "medium", "type" => "fixed" },
        ]
        assert_equal(
          [
            { "color" => "red", "size" => "large", "type" => "fixed" },
          ],
          @filter.where_exp(
            sample, "item", "item.type == 'fixed' and item.color == 'red' or item.color == 'teal'"
          )
        )
      end

      it "stringifies during comparison for compatibility with liquid parsing" do
        hash = {
          "The Words" => { "rating" => 1.2, "featured" => false },
          "Limitless" => { "rating" => 9.2, "featured" => true },
          "Hustle"    => { "rating" => 4.7, "featured" => true },
        }

        results = @filter.where_exp(hash, "item", "item.featured == true")
        assert_equal 2, results.length
        assert_equal 9.2, results[0]["rating"]
        assert_equal 4.7, results[1]["rating"]

        results = @filter.where_exp(hash, "item", "item.rating == 4.7")
        assert_equal 1, results.length
        assert_equal 4.7, results[0]["rating"]
      end

      it "filters with other operators" do
        assert_equal [3, 4, 5], @filter.where_exp([1, 2, 3, 4, 5], "n", "n >= 3")
      end

      objects = [
        { "id" => "a", "groups" => [1, 2] },
        { "id" => "b", "groups" => [2, 3] },
        { "id" => "c" },
        { "id" => "d", "groups" => [1, 3] },
      ]
      it "filters with the contains operator over arrays" do
        results = @filter.where_exp(objects, "obj", "obj.groups contains 1")
        assert_equal 2, results.length
        assert_equal "a", results[0]["id"]
        assert_equal "d", results[1]["id"]
      end

      it "filters with the contains operator over hash keys" do
        results = @filter.where_exp(objects, "obj", "obj contains 'groups'")
        assert_equal 3, results.length
        assert_equal "a", results[0]["id"]
        assert_equal "b", results[1]["id"]
        assert_equal "d", results[2]["id"]
      end

      it "filters posts" do
        site = fixture_site.tap(&:read)
        posts = site.site_payload["collections"]["posts"].resources
        results = @filter.where_exp(posts, "obj", "obj.data.title == 'Foo Bar'")
        assert_equal 1, results.length
        assert_equal site.collections.posts.resources.find { |p| p.data.title == "Foo Bar" }, results.first
      end

      it "always returns an array if the object responds to 'select'" do
        results = @filter.where_exp(SelectDummy.new, "obj", "1 == 1")
        assert_equal [], results
      end

      it "filters by variable values" do
        @filter.site.tap(&:read)
        posts = @filter.site.site_payload["collections"]["posts"].resources
        results = @filter.where_exp(posts, "post",
                                    "post.date > site.dont_show_posts_before")
        assert_equal posts.count { |p| p.date > @sample_time }, results.length
      end
    end

    describe "in_locale filter" do
      it "filters by current site locale" do
        filter = make_filter_mock(
          available_locales: [:en, :es]
        )
        filter.site.read
        posts = filter.site.site_payload["collections"]["posts"].resources
        posts.first.data[:locale] = "es"
        filter.site.locale = :es
        results = filter.in_locale(posts)
        assert_equal 1, results.length
      end
    end

    describe "group_by_exp filter" do
      it "successfully groups array of Bridgetown::Page's" do
        @filter.site.process
        groups = @filter.group_by_exp(@filter.site.collections.pages.resources, "page", "page.layout | upcase")
        groups.each do |g|
          assert(
            ["DEFAULT",
             "ERBLAYOUT",
             "SERBLAYOUT",
             "EXAMPLE/TEST_LAYOUT",
             "EXAMPLE/OVERRIDDEN_LAYOUT",
             "NIL",
             "",].include?(g["name"]),
            "#{g["name"]} isn't a valid grouping."
          )
          case g["name"]
          when "DEFAULT"
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for 'default' is not an Array."
            )
            assert_equal 5, g["items"].size
          when "nil"
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for 'nil' is not an Array."
            )
            assert_equal 2, g["items"].size
          when ""
            assert(
              g["items"].is_a?(Array),
              "The list of grouped items for '' is not an Array."
            )
            assert_equal 19, g["items"].size
          end
        end
      end

      it "includes the size of each grouping" do
        groups = @filter.group_by_exp(@filter.site.collections.pages.resources, "page", "page.layout")
        groups.each do |g|
          assert_equal(
            g["items"].size,
            g["size"],
            "The size property for '#{g["name"]}' doesn't match the size of the Array."
          )
        end
      end

      it "allows more complex filters" do
        items = [
          { "version" => "1.0", "result" => "slow" },
          { "version" => "1.1.5", "result" => "medium" },
          { "version" => "2.7.3", "result" => "fast" },
        ]

        result = @filter.group_by_exp(items, "item", "item.version | split: '.' | first")
        assert_equal 2, result.size
      end

      it "is equivalent of group_by" do
        actual = @filter.group_by_exp(@filter.site.collections.pages.resources, "page", "page.layout")
        expected = @filter.group_by(@filter.site.collections.pages.resources, "layout")

        assert_equal expected, actual
      end

      it "returns any input that is not an array" do
        assert_equal "some string", @filter.group_by_exp("some string", "la", "le")
      end

      it "groups by full element (as opposed to a field of the element)" do
        items = %w(a b c d)

        result = @filter.group_by_exp(items, "item", "item")
        assert_equal 4, result.length
        assert_equal ["a"], result.first["items"]
      end

      it "accepts hashes" do
        hash = { 1 => "a", 2 => "b", 3 => "c", 4 => "d" }

        result = @filter.group_by_exp(hash, "item", "item")
        assert_equal 4, result.length
      end
    end

    describe "sort filter" do
      it "raises Exception when input is nil" do
        err = assert_raises ArgumentError do
          @filter.sort(nil)
        end
        assert_equal "Cannot sort a null object.", err.message
      end
      it "returns sorted numbers" do
        assert_equal [1, 2, 2.2, 3], @filter.sort([3, 2.2, 2, 1])
      end
      it "returns sorted strings" do
        assert_equal %w(10 2), @filter.sort(%w(10 2))
        assert_equal %w(FOO Foo foo), @filter.sort(%w(foo Foo FOO))
        assert_equal %w(_foo foo foo_), @filter.sort(%w(foo_ _foo foo))
        # Cyrillic
        assert_equal %w(ВУЗ Вуз вуз), @filter.sort(%w(Вуз вуз ВУЗ))
        assert_equal %w(_вуз вуз вуз_), @filter.sort(%w(вуз_ _вуз вуз))
        # Hebrew
        assert_equal %w(אלף בית), @filter.sort(%w(בית אלף))
      end
      it "returns sorted by property array" do
        assert_equal [{ "a" => 1 }, { "a" => 2 }, { "a" => 3 }, { "a" => 4 }],
                     @filter.sort([{ "a" => 4 }, { "a" => 3 }, { "a" => 1 }, { "a" => 2 }], "a")
      end
      it "returns sorted by property array with numeric strings sorted as numbers" do
        assert_equal([{ "a" => ".5" }, { "a" => "0.65" }, { "a" => "10" }],
                     @filter.sort([{ "a" => "10" }, { "a" => ".5" }, { "a" => "0.65" }], "a"))
      end
      it "returns sorted by property array with numeric strings first" do
        assert_equal([{ "a" => ".5" }, { "a" => "0.6" }, { "a" => "twelve" }],
                     @filter.sort([{ "a" => "twelve" }, { "a" => ".5" }, { "a" => "0.6" }], "a"))
      end
      it "returns sorted by property array with numbers and strings " do
        assert_equal([{ "a" => "1" }, { "a" => "1abc" }, { "a" => "20" }],
                     @filter.sort([{ "a" => "20" }, { "a" => "1" }, { "a" => "1abc" }], "a"))
      end
      it "returns sorted by property array with nils first" do
        ary = [{ "a" => 2 }, { "b" => 1 }, { "a" => 1 }]
        assert_equal [{ "b" => 1 }, { "a" => 1 }, { "a" => 2 }], @filter.sort(ary, "a")
        assert_equal @filter.sort(ary, "a"), @filter.sort(ary, "a", "first")
      end
      it "returns sorted by property array with nils last" do
        assert_equal [{ "a" => 1 }, { "a" => 2 }, { "b" => 1 }],
                     @filter.sort([{ "a" => 2 }, { "b" => 1 }, { "a" => 1 }], "a", "last")
      end
      it "returns sorted by subproperty array" do
        assert_equal [{ "a" => { "b" => 1 } }, { "a" => { "b" => 2 } },
                      { "a" => { "b" => 3 } },],
                     @filter.sort([{ "a" => { "b" => 2 } }, { "a" => { "b" => 1 } },
                                   { "a" => { "b" => 3 } },], "a.b")
      end
    end

    describe "to_integer filter" do
      it "raises Exception when input is not integer or string" do
        assert_raises NoMethodError do
          @filter.to_integer([1, 2])
        end
      end
      it "returns 0 when input is nil" do
        assert_equal 0, @filter.to_integer(nil)
      end
      it "returns integer when input is boolean" do
        assert_equal 0, @filter.to_integer(false)
        assert_equal 1, @filter.to_integer(true)
      end
      it "returns integers" do
        assert_equal 0, @filter.to_integer(0)
        assert_equal 1, @filter.to_integer(1)
        assert_equal 1, @filter.to_integer(1.42857)
        assert_equal(-1, @filter.to_integer(-1))
        assert_equal(-1, @filter.to_integer(-1.42857))
      end
    end

    describe "inspect filter" do
      it "returns a HTML-escaped string representation of an object" do
        assert_equal "{&quot;&lt;a&gt;&quot;=&gt;1}", @filter.inspect("<a>" => 1)
      end

      it "quotes strings" do
        assert_equal "&quot;string&quot;", @filter.inspect("string")
      end
    end

    describe "slugify filter" do
      it "returns a slugified string with default mode" do
        reset_mode = @filter.site.config.slugify_mode
        @filter.site.config.slugify_mode = "default"
        assert_equal "q-bert-says", @filter.slugify(" Q*bert says @!#?@!")
        @filter.site.config.slugify_mode = reset_mode
      end

      it "returns a slugified string with mode" do
        assert_equal "q-bert-says-@!-@!", @filter.slugify(" Q*bert says @!#?@!", "pretty")
      end
    end

    describe "titleize filter" do
      it "returns a titliezed string" do
        assert_equal "Q Bert Says Howdy There", @filter.titleize("q-bert_says howdy there")
      end
    end

    describe "push filter" do
      it "returns a new array with the element pushed to the end" do
        assert_equal %w(hi there bernie), @filter.push(%w(hi there), "bernie")
      end
    end

    describe "pop filter" do
      it "returns a new array with the last element popped" do
        assert_equal %w(hi there), @filter.pop(%w(hi there bernie))
      end

      it "allows multiple els to be popped" do
        assert_equal %w(hi there bert), @filter.pop(%w(hi there bert and ernie), 2)
      end

      it "casts string inputs for # into nums" do
        assert_equal %w(hi there bert), @filter.pop(%w(hi there bert and ernie), "2")
      end
    end

    describe "shift filter" do
      it "returns a new array with the element removed from the front" do
        assert_equal %w(a friendly greeting), @filter.shift(%w(just a friendly greeting))
      end

      it "allows multiple els to be shifted" do
        assert_equal %w(bert and ernie), @filter.shift(%w(hi there bert and ernie), 2)
      end

      it "casts string inputs for # into nums" do
        assert_equal %w(bert and ernie), @filter.shift(%w(hi there bert and ernie), "2")
      end
    end

    describe "unshift filter" do
      it "returns a new array with the element put at the front" do
        assert_equal %w(aloha there bernie), @filter.unshift(%w(there bernie), "aloha")
      end
    end

    describe "sample filter" do
      it "returns a random item from the array" do
        input = %w(hey there bernie)
        assert_includes input, @filter.sample(input)
      end

      it "allows sampling of multiple values (n > 1)" do
        input = %w(hey there bernie)
        @filter.sample(input, 2).each do |val|
          assert_includes input, val
        end
      end
    end
  end
end
