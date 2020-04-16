Feature: Markdown
  As a hacker who likes to blog
  I want to be able to make a static site
  In order to share my awesome ideas with the interwebs

  Scenario: Markdown in list on index
    Given I have a configuration file with "paginate" set to "5"
    And I have an "index.html" page that contains "Index - {% for post in site.posts %} {{ post.content }} {% endfor %}"
    And I have a _posts directory
    And I have the following post:
      | title   | date       | content    | type     |
      | Hackers | 2009-03-27 | # My Title | markdown |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Index" in "output/index.html"
    And I should see "<h1 id=\"my-title\">My Title</h1>" in "output/2009/03/27/hackers.html"
    And I should see "<h1 id=\"my-title\">My Title</h1>" in "output/index.html"

  Scenario: Markdown directly on index
    Given I have a configuration file with "paginate" set to "5"
    And I have an "index.md" page with content:
      """
      **Index**

      {% for post in site.posts %}{{ post.content }}{% endfor %}
      """
    And I have a _posts directory
    And I have the following post:
      | title   | date       | content    | type     |
      | Hackers | 2009-03-27 | # My Title | markdown |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<strong>Index</strong>" in "output/index.html"
    And I should see "<h1 id=\"my-title\">My Title</h1>" in "output/2009/03/27/hackers.html"
    And I should see "<h1 id=\"my-title\">My Title</h1>" in "output/index.html"

  Scenario: Markdown in pagination on index
    Given I have a configuration file with:
      | key        | value                        |
      | pagination | {enabled: true, per_page: 5} |
    And I have an "index.md" page configured with pagination "{enabled: true}" with content:
      """
      **Index**
      
      {% for post in paginator.documents %}{{ post.content }}{% endfor %}
      """
    And I have a _posts directory
    And I have the following post:
      | title   | date       | content    | type     |
      | Hackers | 2009-03-27 | # My Title | markdown |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<strong>Index</strong>" in "output/index.html"
    And I should see "<h1 id=\"my-title\">My Title</h1>" in "output/index.html"
