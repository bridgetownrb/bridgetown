Feature: Prototype Pages
  In order to auto-generate category, tag, etc. archives
  As a blog's user
  I want create a prototype page and then divide matching posts in several pages

  Scenario Outline: Generate category pages and paginate
    Given I have a configuration file with:
      | key        | value                              |
      | pagination | { enabled: true, per_page: <num> } |
    And I have a _layouts directory
    And I have a categories directory
    And I have an "categories/category.html" page with prototype "{collection: posts, term: category}" that contains "{{ paginator.resources.size }} {{ paginator.resources[0].title }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | category         | content |
      | Wargames  | 2009-03-27 | This Means War   | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | This Means War   | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | This Means War   | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | This Means War   | The only winning move is not to play4. |
      | Peace5    | 2009-07-27 | This Means Peace | Peace in our time. |
    When I run bridgetown build
    Then the output/categories/this-means-war/page/<exist> directory should exist
    And the "output/categories/this-means-war/page/<exist>/index.html" file should exist
    And I should see "<posts>" in "output/categories/this-means-war/page/<exist>/index.html"
    And the "output/categories/this-means-war/page/<not_exist>/index.html" file should not exist
    And the "output/categories/this-means-peace/index.html" file should exist
    And the output/categories/this-means-peace/page/2 directory should not exist

    Examples:
      | num | exist | posts | not_exist | title     |
      | 1   | 4     | 1     | 5         | Wargames  |
      | 2   | 2     | 2     | 3         | Wargames2 |
      | 3   | 2     | 1     | 3         | Wargames3 |

  Scenario Outline: Generate tag pages and paginate
    Given I have a configuration file with:
      | key        | value                              |
      | pagination | { enabled: true, per_page: <num> } |
    And I have a _layouts directory
    And I have a tags directory
    And I have an "tags/tag.html" page with prototype "{collection: posts, term: tag}" that contains "#{{ page.tag }} {{ paginator.resources.size }} {{ paginator.resources[0].title }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | tags                    | content |
      | Wargames  | 2009-03-27 | strange difficult       | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | strange, scary          | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | ["awful news", "scary"] | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | terrible scary          | The only winning move is not to play4. |
    When I run bridgetown build
    Then the output/tags/scary/page/<exist> directory should exist
    And the "output/tags/scary/page/<exist>/index.html" file should exist
    And I should see "#scary" in "output/tags/scary/page/<exist>/index.html"
    And I should see "<posts>" in "output/tags/scary/page/<exist>/index.html"
    And the "output/tags/scary/page/<not_exist>/index.html" file should not exist
    And the "output/tags/awful-news/index.html" file should exist

    Examples:
      | num | exist | posts | not_exist | title     |
      | 1   | 3     | 1     | 4         | Wargames2 |
      | 2   | 2     | 2     | 3         | Wargames3 |

  Scenario Outline: Generate author pages and paginate
    Given I have a configuration file with:
      | key        | value                              |
      | pagination | { enabled: true, per_page: <num> } |
    And I have a _layouts directory
    And I have a authors directory
    And I have an "authors/author.html" page with prototype "{collection: posts, term: author}" that contains "{{ paginator.resources.size }} {{ paginator.resources[0].title }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | author                | content |
      | Wargames  | 2009-03-27 | ["john doe", "jenny"] | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | jackson               | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | melinda, jackson      | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | fred ; jackson        | The only winning move is not to play4. |
    When I run bridgetown build
    Then the output/authors/jackson/page/<exist> directory should exist
    And the "output/authors/jackson/page/<exist>/index.html" file should exist
    And I should see "<posts>" in "output/authors/jackson/page/<exist>/index.html"
    And the "output/authors/jackson/page/<not_exist>/index.html" file should not exist

    Examples:
      | num | exist | posts | not_exist | title     |
      | 1   | 3     | 1     | 4         | Wargames2 |
      | 2   | 2     | 2     | 3         | Wargames3 |
