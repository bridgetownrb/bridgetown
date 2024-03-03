# frozen_string_literal: true

require "features/feature_helper"

# I want to be able to change the permalinks used for output
class TestPermalinks < BridgetownFeatureTest
  context "permalinks" do
    setup do
      create_directory "_posts"
    end

    should "support custom permalink schema with prefix" do
      create_page "_posts/custom-permalink-schema.md", "Totally custom.", date: "2024-02-27", category: "stuff"

      create_configuration permalink: "/blog/:year/:month/:day/:title/"
      run_bridgetown "build"

      assert_file_contains "Totally custom.", "output/blog/2024/02/27/custom-permalink-schema/index.html"
    end

    should "support custom permalink schema with category" do
      create_page "_posts/custom-permalink-schema.md", "Totally custom.", date: "2024-02-27", category: "stuff"

      create_configuration permalink: "/:categories/:title.html"
      run_bridgetown "build"

      assert_file_contains "Totally custom.", "output/stuff/custom-permalink-schema.html"
    end

    should "support custom permalink schema with date" do
      create_page "_posts/custom-permalink-schema.md", "Totally custom.", date: "2024-02-27", category: "stuff"

      create_configuration permalink: "/:month/:day/:year/:title.html"
      run_bridgetown "build"

      assert_file_contains "Totally custom.", "output/02/27/2024/custom-permalink-schema.html"
    end

    should "support per-post permalink ending in slash" do
      create_page "_posts/some-post.md", "bla bla", title: "Some post", date: "2013-04-14", permalink: "/custom/posts/1/"

      run_bridgetown "build"

      assert_file_contains "bla bla", "output/custom/posts/1/index.html"
    end

    should "support per-post permalink ending in .html" do
      create_page "_posts/some-post.md", "bla bla", title: "Some post", date: "2013-04-14", permalink: "/custom/posts/some.html"

      run_bridgetown "build"

      assert_file_contains "bla bla", "output/custom/posts/some.html"
    end

    should "output in lower case even with mixed-case filenames" do
      create_page "_posts/2024-02-27-Pretty-Permalink-Schema.md", "Totally pretty", title: "pretty"

      create_configuration permalink: "pretty"
      run_bridgetown "build"

      assert_file_contains "Totally pretty", "output/2024/02/27/pretty-permalink-schema/index.html"
    end

    should "output underscores in filenames" do
      create_page "_posts/2024-02-27-Pretty_Permalink-Schema.md", "Totally pretty", title: "pretty"

      create_configuration permalink: "pretty"
      run_bridgetown "build"

      assert_file_contains "Totally pretty", "output/2024/02/27/pretty_permalink-schema/index.html"
    end

    should "support multi-lingual rendering with :lang placeholder" do
      create_page "_posts/2024-02-27-multi-lingual.es.md", "Impresionante!", title: "Custom Locale"

      create_configuration permalink: "/:lang/:year/:month/:day/:slug/", available_locales: %w[en es]
      run_bridgetown "build"

      assert_file_contains "Impresionante!", "output/es/2024/02/27/multi-lingual/index.html"
    end

    should "support multi-lingual rendering along with :title placeholder" do
      create_page "_posts/2024-02-27-multi-lingual.es.md", "Impresionante!", title: "Custom Locale"

      create_configuration permalink: "/:lang/:year/:month/:day/:title/", available_locales: %w[en es]
      run_bridgetown "build"

      assert_file_contains "Impresionante!", "output/es/2024/02/27/custom-locale/index.html"
    end

    should "not support multi-lingual rendering if locales aren't configured" do
      create_page "_posts/2024-02-27-not-multi-lingual.es.md", "Impresionante!", title: "Custom Locale"

      create_configuration permalink: "/:lang/:year/:month/:day/:slug/"
      run_bridgetown "build"

      assert_file_contains "Impresionante!", "output/2024/02/27/not-multi-lingual.es/index.html"
    end

    should "support multi-lingual rendering with multiple locale resources" do
      create_page "_posts/2024-02-27-multi-lingual.md", "Awesome!", title: "English Locale"
      create_page "_posts/2024-02-27-multi-lingual.es.md", "Impresionante!", title: "Custom Locale"

      create_configuration permalink: "/:locale/:year/:month/:day/:slug/", available_locales: %w[en es]
      run_bridgetown "build"

      assert_file_contains "Awesome!", "output/2024/02/27/multi-lingual/index.html"
      assert_file_contains "Impresionante!", "output/es/2024/02/27/multi-lingual/index.html"
    end

    should "support multi-lingual rendering within custom collections" do
      create_directory "_blogs"
      create_page "_blogs/2024-02-27-multi-lingual.md", "Awesome! {{ site.locale }}", title: "English Locale"
      create_page "_blogs/2024-02-27-multi-lingual.es.md", "Impresionante! {{ site.locale }}", title: "Custom Locale"

      create_configuration collections: { blogs: { output: true, permalink: "/:locale/:collection/:slug/" } }, available_locales: %w[en es]
      run_bridgetown "build"

      assert_file_contains "Awesome! en", "output/blogs/multi-lingual/index.html"
      assert_file_contains "Impresionante! es", "output/es/blogs/multi-lingual/index.html"
    end

    should "render a resource with the locale of its front matter key" do
      create_page "_posts/2024-02-27-multi-lingual.md", "Impresionante!", title: "Custom Locale", locale: "es"

      create_configuration permalink: "/:lang/:year/:month/:day/:slug/", available_locales: %w[en es]
      run_bridgetown "build"

      assert_file_contains "Impresionante!", "output/es/2024/02/27/multi-lingual/index.html"
    end

    should "allow a non-HTML file extension" do
      create_page "_posts/2016-01-18-i-am-php.md", "I am PHP", permalink: "/2016/i-am-php.php"
      create_page "i-am-also-php.md", "I am also PHP", permalink: "/i-am-also-php.php"

      run_bridgetown "build"

      assert_file_contains "I am PHP", "output/2016/i-am-php.php"
      assert_file_contains "I am also PHP", "output/i-am-also-php.php"
    end

    should "not add `_pages` to permalink for resources in _pages" do
      create_directory "_pages/test"
      create_page "_pages/test/mypage.md", "I am a page!", title: "Page"
      create_page "_pages/anotherpage.md", "I am another page!", permalink: "/some/other/page.*"

      run_bridgetown "build"

      assert_file_contains "I am a page!", "output/test/mypage/index.html"
      assert_file_contains "I am another page!", "output/some/other/page.html"
    end
  end
end
