# frozen_string_literal: true

require "features/feature_helper"

# I want divide up my post listings across several pages
class TestPagination < BridgetownFeatureTest
  context "paginator" do
    setup do
      create_directory "_posts"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", date: "2009-06-27"
    end

    examples1 = [
      { num: 1, exist: 4, posts: 1, not_exist: 5, title: "Wargames" },
      { num: 2, exist: 2, posts: 2, not_exist: 3, title: "Wargames2" },
      { num: 3, exist: 2, posts: 1, not_exist: 3, title: "Wargames" },
    ]

    examples1.each do |example|
      should "paginate with #{example[:num]} posts per page" do
        create_configuration pagination: { enabled: true, per_page: example[:num] }

        create_page "index.html", "{{ paginator.resources.size }} {{ paginator.resources[0].title }}", pagination: { collection: "posts" }

        run_bridgetown "build"

        assert_file_contains "#{example[:posts]} #{example[:title]}", "output/page/#{example[:exist]}/index.html"
        refute_exist "output/page/#{example[:not_exist]}/index.html"
      end
    end

    examples2 = [
      { exist: 2, posts: 1, not_exist: 5 },
      { exist: 3, posts: 1, not_exist: 6 },
      { exist: 4, posts: 1, not_exist: 7 },
    ]

    examples2.each do |example|
      should "paginate #{example[:exist]} while setting a custom pagination path" do
        create_configuration pagination: { enabled: true, per_page: 1, permalink: "/page-:num/" },
                             permalink: "/blog/:year/:month/:day/:title"

        create_directory "blog"
        create_page "blog/index.html", "{{ paginator.resources.size }}", pagination: { collection: "posts" }

        run_bridgetown "build"

        assert_file_contains example[:posts].to_s, "output/blog/page-#{example[:exist]}/index.html"
        refute_exist "output/blog/page-#{example[:not_exist]}/index.html"
      end
    end
  end

  context "paginator and tags" do
    setup do
      create_directory "_posts"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", tags: "strange difficult", date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", tags: "strange, scary", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", tags: ["awful news", "scary"], date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", tags: "terrible; scary", date: "2009-06-27"
    end

    examples1 = [
      { num: 1, exist: 3, posts: 1, not_exist: 4, title: "Wargames2" },
      { num: 2, exist: 2, posts: 1, not_exist: 3, title: "Wargames2" },
    ]

    examples1.each do |example|
      should "paginate #{example[:num]} posts per page with tags" do
        create_configuration pagination: { enabled: true, per_page: example[:num] }

        create_page "index.html", "{{ paginator.resources.size }} {{ paginator.resources[0].title }}", pagination: { collection: "posts", tag: "scary" }

        run_bridgetown "build"

        assert_file_contains "#{example[:posts]} #{example[:title]}", "output/page/#{example[:exist]}/index.html"
        refute_exist "output/page/#{example[:not_exist]}>/index.html"
      end
    end
  end
end
