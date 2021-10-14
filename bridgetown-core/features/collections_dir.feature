Feature: Collections Directory
  As a hacker who likes to structure content without clutter
  I want to be able to organize my collections under a single directory
  And render them from there

  Scenario: Custom collections_dir containing only posts
    And I have a collections/_posts directory
    And I have the following post within the "collections" directory:
      | title         | date       | content         |
      | Gathered Post | 2009-03-27 | Random Content. |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections_dir: collections
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Random Content." in "output/2009/03/27/gathered-post/index.html"

  Scenario: Rendered collection in custom collections_dir also containing posts
    Given I have a collections/_puppies directory
    And I have the following document under the "puppies" collection within the "collections" directory:
      | title  | date       | content            |
      | Rover  | 2007-12-31 | content for Rover. |
    And I have a collections/_posts directory
    And I have the following post within the "collections" directory:
      | title         | date       | content         |
      | Gathered Post | 2009-03-27 | Random Content. |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true

    collections_dir: collections
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/rover/index.html" file should exist
    And I should see "Random Content." in "output/2009/03/27/gathered-post/index.html"

  Scenario: Rendered collection in custom collections_dir with posts at the site root
    Given I have a collections/_puppies directory
    And I have the following document under the "puppies" collection within the "collections" directory:
      | title  | date       | content            |
      | Rover  | 2007-12-31 | content for Rover. |
    And I have a _posts directory
    And I have the following post:
      | title        | date       | content         |
      | Post At Root | 2009-03-27 | Random Content. |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true

    collections_dir: collections
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/rover/index.html" file should exist
    And the "output/2009/03/27/post-at-root/index.html" file should not exist
    And the output/_posts directory should not exist

  Scenario: A complex site with collections and posts at various locations
    Given I have a gathering/_puppies directory
    And I have a gathering/_posts directory
    And I have a _puppies directory
    And I have a _posts directory
    And I have the following document under the "puppies" collection within the "gathering" directory:
      | title               | date       | content            |
      | Rover in Gathering  | 2007-12-31 | content for Rover. |
    And I have the following document under the puppies collection:
      | title               | date       | content            |
      | Rover At Root       | 2007-12-31 | content for Rover. |
    And I have the following post within the "gathering" directory:
      | title               | date       | content            |
      | Post in Gathering   | 2009-03-27 | Totally nothing.   |
    And I have the following post:
      | title               | date       | content            |
      | Post At Root        | 2009-03-27 | Totally nothing.   |
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      puppies:
        output: true

    collections_dir: gathering
    """
    And I have a "gathering/_puppies/static_file.txt" file that contains "Static content."
    And I have a gathering/_puppies/nested directory
    And I have a "gathering/_puppies/nested/static_file.txt" file that contains "Nested Static content."
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/puppies/rover-in-gathering/index.html" file should exist
    And the "output/2009/03/27/post-in-gathering/index.html" file should exist
    And the "output/puppies/rover-at-root/index.html" file should not exist
    And I should see exactly "Static content." in "output/puppies/static_file.txt"
    And I should see exactly "Nested Static content." in "output/puppies/nested/static_file.txt"
    And the output/gathering directory should not exist
    And the output/_posts directory should not exist

  Scenario: Front matter defaults and custom collections directory
    Given I have a gathering/_players/managers directory
    And I have a gathering/_players/recruits directory
    And I have a gathering/_players/standby directory
    And I have the following documents nested inside "managers" directory under the "players" collection within the "gathering" directory:
      | title          | content             |
      | Tony Stark     | content for Tony.   |
      | Steve Rogers   | content for Steve.  |
    And I have the following documents nested inside "recruits" directory under the "players" collection within the "gathering" directory:
      | title          | content             |
      | Peter Parker   | content for Peter.  |
      | Wanda Maximoff | content for Wanda.  |
    And I have the following documents nested inside "standby" directory under the "players" collection within the "gathering" directory:
      | title          | content             |
      | Thanos         | content for Thanos. |
      | Loki           | content for Loki.   |
    And I have a "bridgetown.config.yml" file with content:
    """
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
    """
    And I have a "index.md" file with content:
    """
    ---
    ---
    {% for player in collections.players.resources %}
      <p>{{ player.title }}: Manager: {{ player.manager }}</p>
      <p>{{ player.title }}: Recruit: {{ player.recruit }}</p>
      <p>{{ player.title }}: Villain: {{ player.villain }}</p>
    {% endfor %}
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<p>Tony Stark: Manager: true</p>" in "output/index.html"
    And I should see "<p>Tony Stark: Recruit: false</p>" in "output/index.html"
    And I should see "<p>Tony Stark: Villain: false</p>" in "output/index.html"
    And I should see "<p>Peter Parker: Manager: false</p>" in "output/index.html"
    And I should see "<p>Peter Parker: Recruit: true</p>" in "output/index.html"
    And I should see "<p>Peter Parker: Villain: false</p>" in "output/index.html"
    And I should see "<p>Steve Rogers: Manager: true</p>" in "output/index.html"
    And I should see "<p>Steve Rogers: Recruit: false</p>" in "output/index.html"
    And I should see "<p>Steve Rogers: Villain: false</p>" in "output/index.html"
    And I should see "<p>Wanda Maximoff: Manager: false</p>" in "output/index.html"
    And I should see "<p>Wanda Maximoff: Recruit: true</p>" in "output/index.html"
    And I should see "<p>Wanda Maximoff: Villain: false</p>" in "output/index.html"
    And I should see "<p>Thanos: Manager: false</p>" in "output/index.html"
    And I should see "<p>Thanos: Recruit: false</p>" in "output/index.html"
    And I should see "<p>Thanos: Villain: true</p>" in "output/index.html"
    And I should see "<p>Loki: Manager: false</p>" in "output/index.html"
    And I should see "<p>Loki: Recruit: false</p>" in "output/index.html"
    And I should see "<p>Loki: Villain: false</p>" in "output/index.html"

  Scenario: Sort all entries by a Front Matter key defined in all entries
    Given I have an "index.html" page that contains "Collections: {{ collections.tutorials.resources | map: 'title' | join: ', ' }}"
    And I have fixture collections in "gathering" directory
    And I have a _layouts directory
    And I have a "_layouts/tutorial.html" file with content:
    """
    {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

    {% if page.next %}Next: {{ page.next.title }}{% endif %}
    """
    And I have a "bridgetown.config.yml" file with content:
    """
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
    And I have fixture collections in "gathering" directory
    And I have a _layouts directory
    And I have a "_layouts/tutorial.html" file with content:
    """
    {% if page.previous %}Previous: {{ page.previous.title }}{% endif %}

    {% if page.next %}Next: {{ page.next.title }}{% endif %}
    """
    And I have a "bridgetown.config.yml" file with content:
    """
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

    """
    When I run bridgetown build
    Then I should get a zero exit status
    Then the output directory should exist
    And I should see "'approx_time' not defined" in the build output
    And I should see "Collections: Extending with Plugins, Let's Roll!, Getting Started, Graduation Day, Dive-In and Publish Already!, Tip of the Iceberg" in "output/index.html"
    And I should see "Previous: Getting Started" in "output/tutorials/graduation-day/index.html"
    And I should see "Next: Dive-In and Publish Already!" in "output/tutorials/graduation-day/index.html"
