# frozen_string_literal: true

require "features/feature_helper"

# I want to be able to configure and verify rendering characteristics of collections
class TestCollectionRendering < BridgetownFeatureTest
  context "collections" do
    setup do
      setup_collections_fixture
    end

    should "not render if configuration doesn't have output: true" do
      create_file "_methods/static-file.txt", "Static Content"
      create_configuration collections: ["methods"]
      run_bridgetown "build"

      refute_exist "output/methods"
      refute_exist "output/methods/configuration.html"
      refute_exist "output/methods/static-file.txt"
    end

    should "render if configuration has output: true" do
      create_page "index.liquid", "Collections: output => {{ collections.methods.output }} label => {{ collections.methods.label }}", title: "Index"
      create_page "collection_metadata.liquid", "Methods metadata: {{ collections.methods.foo }}", title: "Metadata"
      create_file "_methods/static-file.txt", "Static Content {{ site.title }}"

      create_configuration collections: { methods: { output: true, foo: "bar" } }
      run_bridgetown "build"

      assert_file_contains "Collections: output => true", "output/index.html"
      assert_file_contains "label => methods", "output/index.html"
      assert_file_contains "Methods metadata: bar", "output/collection_metadata/index.html"
      assert_file_contains "<p>Whatever: foo.bar</p>", "output/methods/configuration/index.html"
      assert_file_contains "Static Content {{ site.title }}", "output/methods/static-file.txt"
    end

    should "render with custom permalink" do
      create_configuration collections: { methods: { output: true, permalink: "/cols/:collection/:path/" } }
      run_bridgetown "build"

      assert_file_contains "<p>Whatever: foo.bar</p>", "output/cols/methods/configuration/index.html"
    end

    should "gather all resources up into site.resources" do
      create_page "index.liquid", "All documents: {% for doc in site.resources %}{{ doc.relative_path }} {% endfor %}", title: "Index"

      create_configuration collections: ["methods"]
      run_bridgetown "build"

      assert_file_contains "All documents: _methods/3940394-21-9393050-fifif1323-test.md _methods/collection/entries _methods/configuration.md _methods/escape-+ #%20[].md _methods/sanitized_path.md _methods/site/generate.md _methods/site/initialize.md _methods/trailing-dots...md _methods/um_hi.md", "output/index.html"
    end

    should "be filterable in Liquid by where" do
      create_page "index.liquid", "{% assign items = collections.methods.resources | where: 'whatever','foo.bar' %}Item count: {{ items.size }}", title: "Index"

      create_configuration collections: ["methods"]
      run_bridgetown "build"

      assert_file_contains "Item count: 2", "output/index.html"
    end

    should "output dateless files" do
      create_page "index.liquid", "Collections: {% for method in collections.thanksgiving.resources %}{{ method.title }} {% endfor %}", title: "Index"

      create_configuration collections: { thanksgiving: { output: true } }
      run_bridgetown "build"

      assert_file_contains "Thanksgiving Black Friday", "output/index.html"
      assert_file_contains "Happy Thanksgiving", "output/thanksgiving/thanksgiving/index.html"
      assert_file_contains "Black Friday", "output/thanksgiving/black-friday/index.html"
    end
  end

  context "collection sorting" do
    setup do
      setup_collections_fixture
      create_directory "_layouts"
    end

    should "sort based on configured front matter key" do
      create_page "index.liquid", "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}", title: "Index"
      create_file "_layouts/tutorial.html", <<~LIQUID
        {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

        {% if page.next %}Next: {{ page.next.title }}{% endif %}
      LIQUID

      create_file "_tutorials/_defaults.yml", "layout: tutorial"

      create_configuration collections: { tutorials: { output: true, sort_by: "lesson" } }
      run_bridgetown "build"

      assert_file_contains "Collections: Getting Started, Let's Roll!, Dive-In and Publish Already!, Tip of the Iceberg, Extending with Plugins, Graduation Day", "output/index.html"
      refute_file_contains "Previous: Graduation Day", "output/tutorials/lets-roll/index.html"
      refute_file_contains "Next: Tip of the Iceberg", "output/tutorials/lets-roll/index.html"
      assert_file_contains "Previous: Getting Started", "output/tutorials/lets-roll/index.html"
      assert_file_contains "Next: Dive-In and Publish Already!", "output/tutorials/lets-roll/index.html"
    end

    should "sort even when front matter key is sometimes missing" do
      create_page "index.liquid", "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}", title: "Index"
      create_file "_layouts/tutorial.html", <<~LIQUID
        {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

        {% if page.next %}Next: {{ page.next.title }}{% endif %}
      LIQUID

      create_file "_tutorials/_defaults.yml", "layout: tutorial"

      create_configuration collections: { tutorials: { output: true, sort_by: "approx_time" } }
      _, output = run_bridgetown "build"

      assert_includes output, "'approx_time' not defined"
      assert_file_contains "Collections: Extending with Plugins, Let's Roll!, Getting Started, Graduation Day, Dive-In and Publish Already!, Tip of the Iceberg", "output/index.html"
      assert_file_contains "Previous: Getting Started", "output/tutorials/graduation-day/index.html"
      assert_file_contains "Next: Dive-In and Publish Already!", "output/tutorials/graduation-day/index.html"
    end
  end

  # TODO: implement this Cucumber test
  #
  # Scenario: Access unrendered collection with future date and unpublished flag via Liquid
  #   Given I have a _puppies directory
  #   And I have the following documents under the puppies collection:
  #     | title  | date       | content             | published |
  #     | Rover  | 2007-12-31 | content for Rover.  | true      |
  #     | Figor  | 2007-12-31 | content for Figor.  | false     |
  #     | Snowy  | 2199-12-31 | content for Snowy.  | true      |
  #     | Hardy  | 2199-12-31 | content for Hardy.  | false     |
  #   And I have a "bridgetown.config.yml" file with content:
  #   """
  #   collections:
  #     puppies:
  #       output: false
  #   """
  #   And I have a "index.md" page that contains "{% for puppy in collections.puppies.resources %}<div>{{ puppy.title }}</div>{% endfor %}"
  #   When I run bridgetown build
  #   Then I should get a zero exit status
  #   And the output directory should exist
  #   And I should see "<div>Rover</div>" in "output/index.html"
  #   But I should not see "<div>Snowy</div>" in "output/index.html"
  #   And I should not see "<div>Figor</div>" in "output/index.html"
  #   And I should not see "<div>Hardy</div>" in "output/index.html"
  #   And the "output/puppies/rover/index.html" file should not exist
  #   And the "output/puppies/snowy/index.html" file should not exist
  #   And the "output/puppies/figor/index.html" file should not exist
  #   And the "output/puppies/hardy/index.html" file should not exist
  #   When I run bridgetown build --unpublished
  #   Then I should get a zero exit status
  #   And the output directory should exist
  #   And I should see "<div>Rover</div>" in "output/index.html"
  #   But I should not see "<div>Snowy</div>" in "output/index.html"
  #   And I should see "<div>Figor</div>" in "output/index.html"
  #   But I should not see "<div>Hardy</div>" in "output/index.html"
  #   And the "output/puppies/rover/index.html" file should not exist
  #   And the "output/puppies/snowy/index.html" file should not exist
  #   And the "output/puppies/figor/index.html" file should not exist
  #   And the "output/puppies/hardy/index.html" file should not exist
  #   When I run bridgetown build --unpublished --future
  #   Then I should get a zero exit status
  #   And the output directory should exist
  #   And I should see "<div>Rover</div>" in "output/index.html"
  #   And I should see "<div>Snowy</div>" in "output/index.html"
  #   And I should see "<div>Figor</div>" in "output/index.html"
  #   But I should see "<div>Hardy</div>" in "output/index.html"
  #   And the "output/puppies/rover/index.html" file should not exist
  #   And the "output/puppies/snowy/index.html" file should not exist
  #   And the "output/puppies/figor/index.html" file should not exist
  #   And the "output/puppies/hardy/index.html" file should not exist
end
