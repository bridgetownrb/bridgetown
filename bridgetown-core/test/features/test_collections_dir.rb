# frozen_string_literal: true

require "features/feature_helper"

# I want to be able to organize my collections under a single directory and render them from there
class TestCollectionsDir < BridgetownFeatureTest
  context "custom collections dir" do
    should "render only posts" do
      create_directory "collections/_posts"
      create_page "collections/_posts/gathered-post.md", "Random Content.", title: "Gathered Post", date: "2009-03-27"

      create_configuration collections_dir: "collections"
      run_bridgetown "build"

      assert_file_contains "Random Content.", "output/2009/03/27/gathered-post/index.html"
    end

    should "render posts and a custom collection" do
      create_directory "collections/_puppies"
      create_page "collections/_puppies/rover.md", "Content for Rover.", title: "Rover", date: "2007-12-31"
      create_directory "collections/_posts"
      create_page "collections/_posts/gathered-post.md", "Random Content.", title: "Gathered Post", date: "2009-03-27"

      create_configuration collections_dir: "collections", collections: {
        puppies: {
          output: true,
        },
      }
      run_bridgetown "build"

      assert_file_contains "Content for Rover.", "output/puppies/rover/index.html"
      assert_file_contains "Random Content.", "output/2009/03/27/gathered-post/index.html"
    end

    should "render a custom collection but not posts at root" do
      create_directory "collections/_puppies"
      create_page "collections/_puppies/rover.md", "Content for Rover.", title: "Rover", date: "2007-12-31"
      create_directory "_posts"
      create_page "_posts/gathered-post.md", "Random Content.", title: "Gathered Post", date: "2009-03-27"

      create_configuration collections_dir: "collections", collections: {
        puppies: {
          output: true,
        },
      }
      run_bridgetown "build"

      assert_file_contains "Content for Rover.", "output/puppies/rover/index.html"
      refute_exist "output/2009/03/27/gathered-post/index.html"
    end

    should "render a complex site with collections and static files" do
      create_directory "gathering/_puppies"
      create_directory "gathering/_posts"
      create_directory "_puppies"
      create_directory "_posts"

      create_page "gathering/_puppies/rover-gathering.md", "Content for Rover.", title: "Rover in Gathering", date: "2007-12-31"
      create_page "_puppies/rover-root.md", "Root Rover.", title: "Rover at Root", date: "2007-12-31"
      create_page "gathering/_posts/gathered-post.md", "Random Content in Gathering.", title: "Gathered Post", date: "2009-03-27"
      create_page "_posts/root-post.md", "Random Root Content.", title: "Root Post", date: "2009-03-27"

      create_file "gathering/_puppies/static_file.txt", "Static content."
      create_directory "gathering/_puppies/nested"
      create_file "gathering/_puppies/nested/static_file.txt", "Nested Static content."

      create_configuration collections_dir: "gathering", collections: {
        puppies: {
          output: true,
        },
      }
      run_bridgetown "build"

      assert_file_contains "Content for Rover", "output/puppies/rover-gathering/index.html"
      assert_file_contains "Random Content in Gathering", "output/2009/03/27/gathered-post/index.html"
      refute_exist "output/puppies/rover-at-root/index.html"
      assert_file_contains "Static content.", "output/puppies/static_file.txt"
      assert_file_contains "Nested Static content.", "output/puppies/nested/static_file.txt"
      refute_exist "output/gathering directory"
      refute_exist "output/_posts directory"
    end
  end

  context "front matter with custom collections" do
    should "render nested documents" do
      create_directory "gathering/_players/managers"
      create_directory "gathering/_players/recruits"
      create_directory "gathering/_players/standby"

      create_page "gathering/_players/managers/tony-stark.md", "content for Tony.", title: "Tony Stark"
      create_page "gathering/_players/managers/steve-rogers.md", "content for Steve.", title: "Steve Rogers"

      create_page "gathering/_players/recruits/peter-parker.md", "content for Peter.", title: "Peter Parker"
      create_page "gathering/_players/recruits/wanda-maximoff.md", "content for Wanda.", title: "Wanda Maximoff"

      create_page "gathering/_players/standby/thanos.md", "content for Thanos.", title: "Thanos"
      create_page "gathering/_players/standby/loki.md", "content for Loki.", title: "Loki"

      create_file "bridgetown.config.yml", <<~YAML
        collections_dir: gathering
        collections: ["players"]
        defaults:
        - scope:
            path: ""
            type: players
          values:
            recruit: false
            manager: false
            villain: false
        - scope:
            path: gathering/_players/standby/thanos.md
            type: players
          values:
            villain: true
        - scope:
            path: gathering/_players/managers/*
            type: players
          values:
            manager: true
        - scope:
            path: gathering/_players/recruits/*
            type: players
          values:
            recruit: true
      YAML

      create_file "index.md", <<~LIQUID
        ---
        ---
        {% for player in collections.players.resources %}
          <p>{{ player.title }}: Manager: {{ player.manager }}</p>
          <p>{{ player.title }}: Recruit: {{ player.recruit }}</p>
          <p>{{ player.title }}: Villain: {{ player.villain }}</p>
        {% endfor %}
      LIQUID

      run_bridgetown "build"

      assert_file_contains "<p>Tony Stark: Manager: true</p>", "output/index.html"
      assert_file_contains "<p>Tony Stark: Recruit: false</p>", "output/index.html"
      assert_file_contains "<p>Tony Stark: Villain: false</p>", "output/index.html"
      assert_file_contains "<p>Peter Parker: Manager: false</p>", "output/index.html"
      assert_file_contains "<p>Peter Parker: Recruit: true</p>", "output/index.html"
      assert_file_contains "<p>Peter Parker: Villain: false</p>", "output/index.html"
      assert_file_contains "<p>Steve Rogers: Manager: true</p>", "output/index.html"
      assert_file_contains "<p>Steve Rogers: Recruit: false</p>", "output/index.html"
      assert_file_contains "<p>Steve Rogers: Villain: false</p>", "output/index.html"
      assert_file_contains "<p>Wanda Maximoff: Manager: false</p>", "output/index.html"
      assert_file_contains "<p>Wanda Maximoff: Recruit: true</p>", "output/index.html"
      assert_file_contains "<p>Wanda Maximoff: Villain: false</p>", "output/index.html"
      assert_file_contains "<p>Thanos: Manager: false</p>", "output/index.html"
      assert_file_contains "<p>Thanos: Recruit: false</p>", "output/index.html"
      assert_file_contains "<p>Thanos: Villain: true</p>", "output/index.html"
      assert_file_contains "<p>Loki: Manager: false</p>", "output/index.html"
      assert_file_contains "<p>Loki: Recruit: false</p>", "output/index.html"
      assert_file_contains "<p>Loki: Villain: false</p>", "output/index.html"
    end

    should "sort all entries by a Front Matter key" do
      create_directory "gathering"
      setup_collections_fixture "gathering"

      create_page "index.html", "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}", title: "Simple Test"

      create_directory "_layouts"
      create_file "_layouts/tutorial.html", <<~LIQUID
        {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

        {% if page.next %}Next: {{ page.next.title }}{% endif %}
      LIQUID

      create_file "bridgetown.config.yml", <<~YAML
        collections_dir: gathering
        collections:
          tutorials:
            output: true
            sort_by: lesson

        defaults:
          - scope:
              path: ""
              type: tutorials
            values:
              layout: tutorial
      YAML

      run_bridgetown "build"

      assert_file_contains "Collections: Getting Started, Let's Roll!, Dive-In and Publish Already!, Tip of the Iceberg, Extending with Plugins, Graduation Day", "output/index.html"
      refute_file_contains "Previous: Graduation Day", "output/tutorials/lets-roll/index.html"
      refute_file_contains "Next: Tip of the Iceberg", "output/tutorials/lets-roll/index.html"
      assert_file_contains "Previous: Getting Started", "output/tutorials/lets-roll/index.html"
      assert_file_contains "Next: Dive-In and Publish Already!", "output/tutorials/lets-roll/index.html"
    end

    should "sort all entries by a Front Matter key defined in only some entries" do
      create_directory "gathering"
      setup_collections_fixture "gathering"

      create_page "index.html", "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}", title: "Simple Test"

      create_directory "_layouts"
      create_file "_layouts/tutorial.html", <<~LIQUID
        {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

        {% if page.next %}Next: {{ page.next.title }}{% endif %}
      LIQUID

      create_file "bridgetown.config.yml", <<~YAML
        collections_dir: gathering
        collections:
          tutorials:
            output: true
            sort_by: approx_time

        defaults:
          - scope:
              path: ""
              type: tutorials
            values:
              layout: tutorial
      YAML

      _, output = run_bridgetown "build"

      assert_includes output, "'approx_time' not defined"

      assert_file_contains "Collections: Extending with Plugins, Let's Roll!, Getting Started, Graduation Day, Dive-In and Publish Already!, Tip of the Iceberg", "output/index.html"
      assert_file_contains "Previous: Getting Started", "output/tutorials/graduation-day/index.html"
      assert_file_contains "Next: Dive-In and Publish Already!", "output/tutorials/graduation-day/index.html"
    end
  end
end
