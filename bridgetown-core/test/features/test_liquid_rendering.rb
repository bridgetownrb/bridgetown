# frozen_string_literal: true

require "features/feature_helper"

# Render content with Liquid and place in Layouts
class TestLiquidRendering < BridgetownFeatureTest
  context "Liquid templates" do
    should "pull resource data into layout" do
      create_page "index.html", "", layout: "simple", author: "John Doe"

      create_directory "_layouts"
      create_file "_layouts/simple.liquid", "{{ page.author }}:{{ resource.author }}:{{ resource.data.author }}"

      run_bridgetown "build"

      assert_file_contains "John Doe:John Doe:John Doe", "output/index.html"
    end

    should "support a site with parentheses in its path name" do
      create_directory "omega(beta)"
      create_directory "omega(beta)/_components"
      create_directory "omega(beta)/_layouts"

      create_page "omega(beta)/test.md", "Hello World", layout: "simple"
      create_file "omega(beta)/_components/head.liquid", "Snippet"
      create_file "omega(beta)/_layouts/simple.liquid", "{% render 'head' %}: {{ content }}"

      create_configuration source: "src/omega(beta)"
      run_bridgetown "build"

      assert_file_contains "Snippet: <p>Hello World</p>", "output/test/index.html"
    end
  end

  context "bad Liquid" do
    should "throws exception" do
      create_page "index.liquid", "{% BLAH %}", layout: "simple"

      create_directory "_layouts"
      create_file "_layouts/simple.liquid", "{{ content }}"

      process, output = run_bridgetown "build", skip_status_check: true

      refute process.exitstatus.zero?
      assert_includes output, "Liquid Exception"
    end

    should "component throws exception" do
      create_directory "_components"
      create_file "_components/invalid.liquid", "{% INVALID %}"

      create_directory "_layouts"
      create_file "_layouts/simple.liquid", "{{ content }}"

      create_page "index.liquid", "{% render 'invalid' %}", layout: "simple"

      process, output = run_bridgetown "build", skip_status_check: true

      refute process.exitstatus.zero?
      assert_includes output, "Liquid syntax error \(line 1\): Unknown tag 'INVALID'"
    end

    should "component with weird filter throws exception" do
      create_directory "_components"
      create_file "_components/invalid.liquid", "{{ site.title | prepend 'Prepended Text' }}"

      create_directory "_layouts"
      create_file "_layouts/simple.liquid", "{{ content }}"

      create_page "index.liquid", "{% render 'invalid' %}", layout: "simple"

      process, output = run_bridgetown "build", skip_status_check: true

      refute process.exitstatus.zero?
      assert_includes output, "Liquid error (invalid line 1): wrong number of arguments (given 1, expected 2)"
    end

    should "not crash simply with a missing filter" do
      create_page "index.liquid", "{{ page.title | foobar }}\n\n{{ page.author }}", title: "Simple Test"

      _, output = run_bridgetown "build"

      refute_includes output, "Liquid Exception:"
    end
  end

  context "strict Liquid" do
    should "fail on non-existent variable" do
      create_page "index.liquid", "{{ page.title }}\n\n{{ page.author }}", title: "Simple Test"

      create_configuration liquid: { strict_variables: true }

      process, output = run_bridgetown "build", skip_status_check: true

      refute process.exitstatus.zero?
      assert_includes output, "Liquid error (line 3): undefined variable author"
    end

    should "fail on non-existent filter" do
      create_page "index.liquid", "{{ page.title }}\n\n{{ page.author | foobar }}", author: "Jane Doe"

      create_configuration liquid: { strict_filters: true }

      process, output = run_bridgetown "build", skip_status_check: true

      refute process.exitstatus.zero?
      assert_includes output, "Liquid error (line 3): undefined filter foobar"
    end
  end

  context "overridden defaults and placed layouts" do
    should "ensure layout set to none doesn't render any layout" do
      create_page "index.md", "Hi there, {{ site.author }}!", layout: "none"

      create_directory "_trials"
      create_page "_trials/no-layout.md", "Hi there, {{ site.author }}!", layout: "none"
      create_page "_trials/false-layout.md", "Hi there, {{ site.author }}!", layout: false
      create_page "test.md", "Hi there, {{ site.author }}!", layout: "page"

      create_directory "_layouts"
      create_file "_layouts/none.liquid", "{{ content }}Welcome!"
      create_file "_layouts/page.liquid", "{{ content }}Check this out!"

      create_configuration author: "John Doe", collections: { trials: { output: true } }, defaults: [
        { scope: { collection: "trials" }, values: { layout: "page" } },
      ]

      _, output = run_bridgetown "build"

      refute_file_contains "Welcome!", "output/trials/no-layout/index.html"
      refute_file_contains "Check this out!", "output/trials/no-layout/index.html"
      refute_file_contains "Check this out!", "output/trials/false-layout/index.html"
      assert_file_contains "<p>Hi there, John Doe!</p>\nCheck this out!", "output/test/index.html"
      assert_file_contains "Hi there, John Doe!", "output/index.html"
      refute_file_contains "Welcome!", "output/index.html"

      refute_includes output, "Build Warning:"
    end
  end

  context "site data" do
    should "render site.time" do
      create_page "index.liquid", "{{ site.time }}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains seconds_agnostic_time(Time.now), "output/index.html"
    end

    should "render posts" do
      create_page "index.liquid", "{{ collections.posts.resources.first.title }}: {{ collections.posts.resources.first.relative_url }}", title: "Simple Test"

      create_directory "_posts"
      %w[First Second Third].each_with_index do |iteration, index|
        create_page "_posts/#{iteration.downcase}-post.html", "content", title: "#{iteration} Post", date: "2009-03-#{index + 25}"
      end

      run_bridgetown "build"

      assert_file_contains "Third Post: /2009/03/27/third-post/", "output/index.html"
    end

    should "render posts in a loop" do
      create_page "index.liquid", "{% for post in collections.posts.resources %} {{ post.title }} {% endfor %}", title: "Simple Test"

      create_directory "_posts"
      %w[First Second Third].each_with_index do |iteration, index|
        create_page "_posts/#{iteration.downcase}-post.html", "content", title: "#{iteration} Post", date: "2009-03-#{index + 25}"
      end

      run_bridgetown "build"

      assert_file_contains "Third Post  Second Post  First Post", "output/index.html"
    end

    should "find posts in category" do
      create_page "index.liquid", "{% for post in site.categories.code %} {{ post.title }} {% endfor %}", title: "Simple Test"

      create_directory "_posts"
      create_page "_posts/awesome-hack.md", "puts 'Hello World'", title: "Awesome Hack", date: "2009-03-26", category: "code"
      create_page "_posts/delicious-beer.md", "1) Yuengling", title: "Delicious Beer", date: "2009-03-26", category: "beer"

      run_bridgetown "build"

      assert_file_contains "Awesome Hack", "output/index.html"
      refute_file_contains "Delicious Beer", "output/index.html"
    end

    should "find posts in tags" do
      create_page "index.liquid", "{% for post in site.tags.beer %} {{ post.content }} {% endfor %}", title: "Simple Test"

      create_directory "_posts"
      create_page "_posts/awesome-hack.md", "puts 'Hello World'", title: "Awesome Hack", date: "2009-03-26", tags: "code"
      create_page "_posts/delicious-beer.md", "1) Yuengling", title: "Delicious Beer", date: "2009-03-26", tags: "beer"

      run_bridgetown "build"

      assert_file_contains "Yuengling", "output/index.html"
      refute_file_contains "Hello World", "output/index.html"
    end
  end

  context "ordering and configuration" do
    should "order posts by name when on the same date" do
      create_page "index.liquid", "{% for post in collections.posts.resources %}{{ post.title }}:{{ post.previous.title}},{{ post.next.title}} {% endfor %}", title: "Simple Test"

      create_directory "_posts"
      create_page "_posts/first.md", "first", title: "first", date: "2009-02-26"
      create_page "_posts/a.md", "A", title: "A", date: "2009-03-26"
      create_page "_posts/b.md", "B", title: "B", date: "2009-03-26"
      create_page "_posts/c.md", "C", title: "C", date: "2009-03-26"
      create_page "_posts/last.md", "last", title: "last", date: "2009-04-26"

      run_bridgetown "build"

      assert_file_contains "last:,C C:last,B B:C,A A:B,first first:A,", "output/index.html"
    end

    should "use configuration date in site payload" do
      create_page "index.liquid", "{{ site.url }}", title: "Simple Test"

      create_configuration url: "http://example.com"

      run_bridgetown "build"

      assert_file_contains "http://example.com", "output/index.html"
    end

    should "render Bridgetown version and environment" do
      create_page "index.liquid", "{{ bridgetown.version }}:{{ bridgetown.environment }}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "#{Bridgetown::VERSION}:test", "output/index.html"
    end
  end
end
