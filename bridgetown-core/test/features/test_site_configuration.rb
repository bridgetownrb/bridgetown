# frozen_string_literal: true

require "features/feature_helper"

# Various ways of re-configuring Bridgetown
class TestSiteConfiguration < BridgetownFeatureTest
  context "directory configuration" do
    should "support different source dir" do
      create_directory "_sourcedir"
      create_page "_sourcedir/index.html", "Changing source directory", title: "Simple test"

      create_configuration source: "src/_sourcedir"

      run_bridgetown "build"

      assert_file_contains "Changing source directory", "output/index.html"
    end

    should "support different destination dir" do
      create_page "index.html", "Changing destination directory", title: "Simple test"

      create_configuration destination: "_mysite"

      run_bridgetown "build"

      assert_file_contains "Changing destination directory", "_mysite/index.html"
    end
  end

  context "exclusion configuration" do
    should "not output certain files" do
      create_file "Rakefile", "I want to be excluded"
      create_file "README", "I want to be excluded"
      create_file "index.html", "I want to be included"
      create_file "Gemfile", "gem 'include-me'"

      create_configuration exclude: %w[Rakefile README]
      run_bridgetown "build"

      assert_file_contains "I want to be included", "output/index.html"
      refute_exist "output/Gemfile"
      refute_exist "output/Rakefile"
      refute_exist "output/README"
    end

    should "output included files even if they're in excluded directories" do
      create_directory "exclude_me"
      create_file "exclude_me/Rakefile", "I want to be excluded"
      create_file "exclude_me/README", "I want to be included"

      create_configuration exclude: %w[exclude_me], include: %w[exclude_me/README]
      run_bridgetown "build"

      assert_file_contains "I want to be included", "output/exclude_me/README"
      refute_exist "output/exclude_me/Rakefile"
    end
  end

  context "future posts" do
    should "not output past site time with future: false" do
      create_directory "_posts"
      create_page "index.html", "site time: {{ site.time | date: '%Y-%m-%d' }}", title: "Simple test"
      create_page "_posts/entry1.md", "content for entry 1", date: "2017-12-31", title: "entry1"
      create_page "_posts/entry2.md", "content for entry 2", date: "2027-01-31", title: "entry2"

      create_configuration time: "2021-01-01", future: false

      run_bridgetown "build"

      assert_file_contains "site time: 2021-01-01", "output/index.html"
      assert_file_contains "<p>content for entry 1</p>", "output/2017/12/31/entry1/index.html"
      refute_exist "output/2027/01/31/entry2/index.html"
    end

    should "output past site time with future: true" do
      create_directory "_posts"
      create_page "index.html", "site time: {{ site.time | date: '%Y-%m-%d' }}", title: "Simple test"
      create_page "_posts/entry1.md", "content for entry 1", date: "2017-12-31", title: "entry1"
      create_page "_posts/entry2.md", "content for entry 2", date: "2027-01-31", title: "entry2"

      create_configuration time: "2021-01-01", future: true

      run_bridgetown "build"

      assert_file_contains "site time: 2021-01-01", "output/index.html"
      assert_file_contains "<p>content for entry 1</p>", "output/2017/12/31/entry1/index.html"
      assert_file_contains "<p>content for entry 2</p>", "output/2027/01/31/entry2/index.html"
    end

    should "output past site time with future CLI flag" do
      create_directory "_posts"
      create_page "index.html", "site time: {{ site.time | date: '%Y-%m-%d' }}", title: "Simple test"
      create_page "_posts/entry1.md", "content for entry 1", date: "2017-12-31", title: "entry1"
      create_page "_posts/entry2.md", "content for entry 2", date: "2027-01-31", title: "entry2"

      create_configuration time: "2021-01-01"

      run_bridgetown "build", "--future"

      assert_file_contains "site time: 2021-01-01", "output/index.html"
      assert_file_contains "<p>content for entry 1</p>", "output/2017/12/31/entry1/index.html"
      assert_file_contains "<p>content for entry 2</p>", "output/2027/01/31/entry2/index.html"
    end
  end

  context "post-specific timezones" do
    should "render dates with the site timezone" do
      create_directory "_layouts"
      create_directory "_posts"
      create_file "_layouts/page.liquid", "Page Layout: {{ collections.posts.resources.size }}"
      create_file "_layouts/post.liquid", "Post Layout: {{ content }} built at {{ page.date | date_to_xmlschema }}"

      create_page "index.html", "site index page", layout: "page"

      create_page "_posts/entry1.md", "content for entry 1", layout: "post", date: "2013-04-09 23:22 -0400"
      create_page "_posts/entry2.md", "content for entry 2", layout: "post", date: "2013-04-10 03:14 -0400"

      create_configuration timezone: "America/New_York"

      run_bridgetown "build"

      assert_file_contains "Page Layout: 2", "output/index.html"
      assert_file_contains "Post Layout: <p>content for entry 1</p>\n built at 2013-04-09T23:22:00-04:00", "output/2013/04/09/entry1/index.html"
      assert_file_contains "Post Layout: <p>content for entry 2</p>\n built at 2013-04-10T03:14:00-04:00", "output/2013/04/10/entry2/index.html"
    end
  end

  context "abritrary layout location" do
    should "not break the build" do
      create_page "index.html", "FOO", layout: "page"
      create_configuration layouts_dir: "../../../../../../../../../../../../../../usr/include"

      run_bridgetown "build"

      assert_file_contains "FOO", "output/index.html"
      refute_file_contains " ", "output/index.html"
    end
  end

  context "Zeitwerk" do
    should "allow collapsed dirs with specific dir name" do
      create_directory "plugins/nested"
      create_file "plugins/nested/top_level.rb", <<~RUBY
        module TopLevel
          Bridgetown::Hooks.register :site, :after_reset do |site|
            pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
            pg.content = "Zeitwerk specific dir"

            site.generated_pages << pg
          end
        end
      RUBY

      create_configuration autoloader_collapsed_paths: ["plugins/nested"]

      run_bridgetown "build"

      assert_file_contains "Zeitwerk specific dir", "output/foo/index.html"
    end

    should "allow collapsed dirs using globs" do
      create_directory "plugins/nested/subnested"
      create_file "plugins/nested/top_level.rb", <<~RUBY
        module TopLevel
          Bridgetown::Hooks.register :site, :after_reset do |site|
            pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
            pg.content = "Zeitwerk glob dir"

            site.generated_pages << pg
          end
        end
      RUBY

      create_file "plugins/nested/subnested/lower_level.rb", <<~RUBY
        module Subnested::LowerLevel
          Bridgetown::Hooks.register :site, :after_reset do |site|
            pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "bar.html")
            pg.content = "Zeitwerk glob subnested dir"

            site.generated_pages << pg
          end
        end
      RUBY

      create_configuration autoloader_collapsed_paths: ["plugins/*"]

      run_bridgetown "build"

      assert_file_contains "Zeitwerk glob dir", "output/foo/index.html"
      assert_file_contains "Zeitwerk glob subnested dir", "output/bar/index.html"
    end
  end
end
