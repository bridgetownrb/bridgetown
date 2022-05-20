Feature: Collections
  As a hacker who likes to structure content
  I want to be able to create collections of similar information
  And render them

  Scenario: Unrendered collection
    Given I have an "index.html" page that contains "Collections: {{ collections.methods.label }}"
    And I have fixture collections
    And I have a "_methods/static-file.txt" file that contains "Static Content {{ site.title }}"
    And I have a configuration file with "collections" set to "['methods']"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    But the output/methods directory should not exist
    And the "output/methods/configuration.html" file should not exist
    And the "output/methods/static-file.txt" file should not exist

  Scenario: Rendered collection
    Given I have an "index.html" page that contains "Collections: output => {{ collections.methods.output }} label => {{ collections.methods.label }}"
    And I have an "collection_metadata.html" page that contains "Methods metadata: {{ collections.methods.foo }}"
    And I have fixture collections
    And I have a "_methods/static-file.txt" file that contains "Static Content {{ site.title }}"
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      methods:
        output: true
        foo:   bar
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Collections: output => true" in "output/index.html"
    And I should see "label => methods" in "output/index.html"
    And I should see "Methods metadata: bar" in "output/collection_metadata/index.html"
    And I should see "<p>Whatever: foo.bar</p>" in "output/methods/configuration/index.html"
    And I should see "Static Content {{ site.title }}" in "output/methods/static-file.txt"

  Scenario: Rendered collection at a custom URL
    Given I have an "index.html" page that contains "Collections: {{ site.collections }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      methods:
        output: true
        permalink: /:collection/:path/
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<p>Whatever: foo.bar</p>" in "output/methods/configuration/index.html"

  Scenario: Rendered document in a layout
    Given I have an "index.html" page that contains "Collections: output => {{ collections.methods.output }} label => {{ collections.methods.label }} foo => {{ collections.methods.foo }}"
    And I have a default layout that contains "<div class='title'>Tom Preston-Werner</div> {{content}}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      methods:
        output: true
        foo:   bar
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Collections: output => true" in "output/index.html"
    And I should see "label => methods" in "output/index.html"
    And I should see "foo => bar" in "output/index.html"
    And I should see "<p>Run your generators! default</p>" in "output/methods/site/generate/index.html"
    And I should see "<div class='title'>Tom Preston-Werner</div>" in "output/methods/site/generate/index.html"

  Scenario: Collections specified as an array
    Given I have an "index.html" page that contains "Collections: {% for method in collections.methods.resources %}{{ method.relative_path }} {% endfor %}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Collections: _methods/3940394-21-9393050-fifif1323-test.md _methods/collection/entries _methods/configuration.md _methods/escape-\+ #%20\[\].md _methods/sanitized_path.md _methods/site/generate.md _methods/site/initialize.md _methods/trailing-dots...md _methods/um_hi.md" in "output/index.html"

  Scenario: Collections specified as an hash
    Given I have an "index.html" page that contains "Collections: {% for method in collections.methods.resources %}{{ method.relative_path }} {% endfor %}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Collections: _methods/3940394-21-9393050-fifif1323-test.md _methods/collection/entries _methods/configuration.md _methods/escape-\+ #%20\[\].md _methods/sanitized_path.md _methods/site/generate.md _methods/site/initialize.md _methods/trailing-dots...md _methods/um_hi.md" in "output/index.html"

  Scenario: Rendered collection with document with future date
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             |
      | Rover  | 2007-12-31 | content for Rover.  |
      | Fido   | 2120-12-31 | content for Fido.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "content for Rover" in "output/puppies/rover/index.html"
    And the "output/puppies/fido/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/fido/index.html" file should exist

  Scenario: Rendered collection with future true metadata
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             |
      | Rover  | 2007-12-31 | content for Rover.  |
      | Fido   | 2120-12-31 | content for Fido.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true
        future: true
    """
    And I have a "index.html" page that contains "Newest puppy: {% assign puppy = collections.puppies.resources.last %}{{ puppy.title }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Newest puppy: Fido" in "output/index.html"
    And I should see "content for Fido" in "output/puppies/fido/index.html"
    And the "output/puppies/fido/index.html" file should exist

  Scenario: Access rendered collection with future dated document via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             |
      | Rover  | 2007-12-31 | content for Rover.  |
      | Fido   | 2120-12-31 | content for Fido.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true
    """
    And I have a "index.html" page that contains "Newest puppy: {% assign puppy = collections.puppies.resources.last %}{{ puppy.title }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Newest puppy: Rover" in "output/index.html"
    But the "output/puppies/fido/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Newest puppy: Fido" in "output/index.html"
    And the "output/puppies/fido/index.html" file should exist

  Scenario: Access rendered and published collection documents via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             | published |
      | Rover  | 2007-12-31 | content for Rover.  | true      |
      | Figor  | 2007-12-31 | content for Figor.  | false     |
      | Snowy  | 2199-12-31 | content for Snowy.  | true      |
      | Hardy  | 2199-12-31 | content for Hardy.  | false     |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true
    """
    And I have a "index.md" page that contains "{% for puppy in collections.puppies.resources %}<div>{{ puppy.title }}</div>{% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    And I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    And I should see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    But I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    But the "output/puppies/snowy/index.html" file should exist

  Scenario: Unrendered collection with future dated document
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             |
      | Rover  | 2007-12-31 | content for Rover.  |
      | Fido   | 2120-12-31 | content for Fido.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: false
    """
    And I have a "foo.txt" file that contains "random static file"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/fido/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/fido/index.html" file should not exist

  Scenario: Access unrendered collection with future dated document via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             |
      | Rover  | 2007-12-31 | content for Rover.  |
      | Fido   | 2120-12-31 | content for Fido.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: false
    """
    And I have a "index.html" page that contains "Newest puppy: {% assign puppy = collections.puppies.resources.last %}{{ puppy.title }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    But I should not see "Newest puppy: Fido" in "output/index.html"
    But the "output/puppies/fido/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Newest puppy: Fido" in "output/index.html"
    And the "output/puppies/fido/index.html" file should not exist

  Scenario: Access unrendered but publishable collection documents via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             | published |
      | Rover  | 2007-12-31 | content for Rover.  | true      |
      | Figor  | 2007-12-31 | content for Figor.  | false     |
      | Snowy  | 2199-12-31 | content for Snowy.  | true      |
      | Hardy  | 2199-12-31 | content for Hardy.  | false     |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: false
    """
    And I have a "index.md" page that contains "{% for puppy in collections.puppies.resources %}<div>{{ puppy.title }}</div>{% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    And I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    And I should see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    But I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist

  Scenario: Access rendered collection with future date and unpublished flag via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             | published |
      | Rover  | 2007-12-31 | content for Rover.  | true      |
      | Figor  | 2007-12-31 | content for Figor.  | false     |
      | Snowy  | 2199-12-31 | content for Snowy.  | true      |
      | Hardy  | 2199-12-31 | content for Hardy.  | false     |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true
    """
    And I have a "index.md" page that contains "{% for puppy in collections.puppies.resources %}<div>{{ puppy.title }}</div>{% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    And I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --unpublished
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should see "<div>Figor</div>" in "output/index.html"
    But I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --unpublished --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    And I should see "<div>Snowy</div>" in "output/index.html"
    And I should see "<div>Figor</div>" in "output/index.html"
    But I should see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should exist
    And the "output/puppies/snowy/index.html" file should exist
    And the "output/puppies/figor/index.html" file should exist
    And the "output/puppies/hardy/index.html" file should exist

  Scenario: Access unrendered collection with future date and unpublished flag via Liquid
    Given I have a _puppies directory
    And I have the following documents under the puppies collection:
      | title  | date       | content             | published |
      | Rover  | 2007-12-31 | content for Rover.  | true      |
      | Figor  | 2007-12-31 | content for Figor.  | false     |
      | Snowy  | 2199-12-31 | content for Snowy.  | true      |
      | Hardy  | 2199-12-31 | content for Hardy.  | false     |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: false
    """
    And I have a "index.md" page that contains "{% for puppy in collections.puppies.resources %}<div>{{ puppy.title }}</div>{% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should not see "<div>Figor</div>" in "output/index.html"
    And I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --unpublished
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    But I should not see "<div>Snowy</div>" in "output/index.html"
    And I should see "<div>Figor</div>" in "output/index.html"
    But I should not see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist
    When I run bridgetown build --unpublished --future
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<div>Rover</div>" in "output/index.html"
    And I should see "<div>Snowy</div>" in "output/index.html"
    And I should see "<div>Figor</div>" in "output/index.html"
    But I should see "<div>Hardy</div>" in "output/index.html"
    And the "output/puppies/rover/index.html" file should not exist
    And the "output/puppies/snowy/index.html" file should not exist
    And the "output/puppies/figor/index.html" file should not exist
    And the "output/puppies/hardy/index.html" file should not exist

  Scenario: All the documents
    Given I have an "index.html" page that contains "All documents: {% for doc in site.resources %}{{ doc.relative_path }} {% endfor %}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "All documents: _methods/3940394-21-9393050-fifif1323-test.md _methods/collection/entries _methods/configuration.md _methods/escape-\+ #%20\[\].md _methods/sanitized_path.md _methods/site/generate.md _methods/site/initialize.md _methods/trailing-dots...md _methods/um_hi.md" in "output/index.html"

  Scenario: Documents have an output attribute, which is the converted HTML
    Given I have an "index.html" page that contains "Second document's output: {{ site.resources[2].output }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Second document's output: <p>Use <code class=\"highlighter-rouge\">Bridgetown.configuration</code> to build a full configuration for use w/Bridgetown.</p>\n\n<p>Whatever: foo.bar</p>" in "output/index.html"

  Scenario: Documents have an output attribute, which is the converted HTML based on site.config
    Given I have an "index.html" page that contains "Second document's output: {{ site.resources[2].output }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    kramdown:
      guess_lang: false
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Second document's output: <p>Use <code>Bridgetown.configuration</code> to build a full configuration for use w/Bridgetown.</p>\n\n<p>Whatever: foo.bar</p>" in "output/index.html"

  Scenario: Filter documents by where
    Given I have an "index.html" page that contains "{% assign items = collections.methods.resources | where: 'whatever','foo.bar' %}Item count: {{ items.size }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Item count: 2" in "output/index.html"

  Scenario: Sort by title
    Given I have an "index.html" page that contains "{% assign items = collections.methods.resources | sort: 'title' %}5. of {{ items.size }}: {{ items[5].output }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "5. of 10: <p>Page without title.</p>" in "output/index.html"

  Scenario: Sort by relative_path
    Given I have an "index.html" page that contains "Collections: {% assign methods = collections.methods.resources | sort: 'relative_path' %}{{ methods | map:"title" | join: ", " }}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
    - methods
    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Collections: this is a test!, Collection#entries, Bridgetown.configuration, Bridgetown.escape, Bridgetown.sanitized_path, Site#generate, Initialize, Ellipsis Path, Site#generate, YAML with Dots" in "output/index.html"

  Scenario: Sort all entries by a Front Matter key defined in all entries
    Given I have an "index.html" page that contains "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}"
    And I have fixture collections
    And I have a _layouts directory
    And I have a "_layouts/tutorial.html" file with content:
    """
    {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

    {% if page.next %}Next: {{ page.next.title }}{% endif %}
    """
    And I have a "bridgetown.config.yml" file with content:
    """
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

    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "Collections: Getting Started, Let's Roll!, Dive-In and Publish Already!, Tip of the Iceberg, Extending with Plugins, Graduation Day" in "output/index.html"
    And I should not see "Previous: Graduation Day" in "output/tutorials/lets-roll/index.html"
    And I should not see "Next: Tip of the Iceberg" in "output/tutorials/lets-roll/index.html"
    But I should see "Previous: Getting Started" in "output/tutorials/lets-roll/index.html"
    And I should see "Next: Dive-In and Publish Already!" in "output/tutorials/lets-roll/index.html"

  Scenario: Sort all entries by a Front Matter key defined in only some entries
    Given I have an "index.html" page that contains "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}"
    And I have fixture collections
    And I have a _layouts directory
    And I have a "_layouts/tutorial.html" file with content:
    """
    {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

    {% if page.next %}Next: {{ page.next.title }}{% endif %}
    """
    And I have a "bridgetown.config.yml" file with content:
    """
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

    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "'approx_time' not defined" in the build output
    And I should see "Collections: Extending with Plugins, Let's Roll!, Getting Started, Graduation Day, Dive-In and Publish Already!, Tip of the Iceberg" in "output/index.html"
    And I should see "Previous: Getting Started" in "output/tutorials/graduation-day/index.html"
    And I should see "Next: Dive-In and Publish Already!" in "output/tutorials/graduation-day/index.html"

  Scenario: Rendered collection with date/dateless filename
    Given I have an "index.html" page that contains "Collections: {% for method in collections.thanksgiving.resources %}{{ method.title }} {% endfor %}"
    And I have fixture collections
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      thanksgiving:
        output: true
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Thanksgiving Black Friday" in "output/index.html"
    And I should see "Happy Thanksgiving" in "output/thanksgiving/thanksgiving/index.html"
    And I should see "Black Friday" in "output/thanksgiving/black-friday/index.html"
