# frozen_string_literal: true

require "features/feature_helper"

# I want to create new paginated pages based on the prototype term like category or tag
class TestPrototypePages < BridgetownFeatureTest
  context "prototype page for categories" do
    setup do
      create_directory "_posts"
      create_directory "categories"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", category: "This Means War", date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", category: "This Means War", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", category: "This Means War", date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", category: "This Means War", date: "2009-06-27"
      create_page "_posts/peace5.md", "Peace in our time.", title: "Peace5", category: "This Means Peace", date: "2009-07-27"
    end

    examples = [
      { num: 1, exist: 4, posts: 1, not_exist: 5, title: "Wargames" },
      { num: 2, exist: 2, posts: 2, not_exist: 3, title: "Wargames2" },
      { num: 3, exist: 2, posts: 1, not_exist: 3, title: "Wargames" },
    ]

    examples.each do |example|
      should "generate category pages and paginate ##{example[:num]}" do
        create_configuration pagination: { enabled: true, per_page: example[:num] }

        create_page "categories/category.liquid", "{{ paginator.resources.size }} {{ paginator.resources[0].title }}", prototype: { collection: "posts", term: "category" }

        run_bridgetown "build"

        assert_file_contains "#{example[:posts]} #{example[:title]}", "output/categories/this-means-war/page/#{example[:exist]}/index.html"
        assert_exist "output/categories/this-means-peace/index.html"
        refute_exist "output/categories/this-means-peace/page/2/index.html"
        refute_exist "output/categories/this-means-page/page/#{example[:not_exist]}/index.html"
      end
    end
  end

  context "prototype page for tags" do
    setup do
      create_directory "_posts"
      create_directory "tags"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", tags: "strange difficult", date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", tags: "strange, scary", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", tags: ["awful news", "scary"], date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", tags: "terrible; scary", date: "2009-06-27"
    end

    examples = [
      { num: 1, exist: 3, posts: 1, not_exist: 4, title: "Wargames2" },
      { num: 2, exist: 2, posts: 1, not_exist: 3, title: "Wargames2" },
    ]

    examples.each do |example|
      should "generate tag pages and paginate ##{example[:num]}" do
        create_configuration pagination: { enabled: true, per_page: example[:num] }

        create_page "tags/tag.liquid", "\#{{ page.tag }} {{ paginator.resources.size }} {{ paginator.resources[0].title }}", prototype: { collection: "posts", term: "tag" }

        run_bridgetown "build"

        assert_file_contains "#scary #{example[:posts]} #{example[:title]}", "output/tags/scary/page/#{example[:exist]}/index.html"
        assert_exist "output/tags/awful-news/index.html"
        refute_exist "output/tags/awful-news/page/2/index.html"
        refute_exist "output/tags/scary/page/#{example[:not_exist]}/index.html"
      end
    end
  end

  context "prototype page for authors" do
    setup do
      create_directory "_posts"
      create_directory "authors"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", author: ["john doe", "jenny"], date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", author: "jackson", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", author: "melinda, jackson", date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", author: "fred ; jackson", date: "2009-06-27"
    end

    examples = [
      { num: 1, exist: 3, posts: 1, not_exist: 4, title: "Wargames2" },
      { num: 2, exist: 2, posts: 1, not_exist: 3, title: "Wargames2" },
    ]

    examples.each do |example|
      should "generate author pages and paginate ##{example[:num]}" do
        create_configuration pagination: { enabled: true, per_page: example[:num] }

        create_page "authors/author.liquid", "\#{{ page.author }} {{ paginator.resources.size }} {{ paginator.resources[0].title }}", prototype: { collection: "posts", term: "author" }

        run_bridgetown "build"

        assert_file_contains "#jackson #{example[:posts]} #{example[:title]}", "output/authors/jackson/page/#{example[:exist]}/index.html"
        assert_exist "output/authors/melinda/index.html"
        refute_exist "output/authors/melinda/page/2/index.html"
        refute_exist "output/authors/jackson/page/#{example[:not_exist]}/index.html"
      end
    end
  end
end
