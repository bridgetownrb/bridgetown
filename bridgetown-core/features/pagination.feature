Feature: Site pagination
  In order to paginate my blog
  As a blog's user
  I want divide the posts in several pages

  Scenario Outline: Paginate with N posts per page
    Given I have a configuration file with:
      | key        | value                              |
      | pagination | { enabled: true, per_page: <num> } |
    And I have a _layouts directory
    And I have an "index.html" page with pagination "{collection: posts}" that contains "{{ paginator.resources.size }} {{ paginator.resources[0].title }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | layout  | content                                |
      | Wargames  | 2009-03-27 | default | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | default | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | default | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | default | The only winning move is not to play4. |
    When I run bridgetown build
    Then the output/page/<exist> directory should exist
    And the "output/page/<exist>/index.html" file should exist
    And I should see "<posts>" in "output/page/<exist>/index.html"
    And the "output/page/<not_exist>/index.html" file should not exist

    Examples:
      | num | exist | posts | not_exist | title     |
      | 1   | 4     | 1     | 5         | Wargames  |
      | 2   | 2     | 2     | 3         | Wargames2 |
      | 3   | 2     | 1     | 3         | Wargames3 |

  Scenario Outline: Setting a custom pagination path
    Given I have a configuration file with:
      | key           | value                          |
      | pagination    | { enabled: true, per_page: 1, permalink: "/page-:num/" } |
      | permalink     | /blog/:year/:month/:day/:title |
    And I have a blog directory
    And I have an "blog/index.html" page with pagination "{collection: posts}" that contains "{{ paginator.resources.size }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | layout  | content                                |
      | Wargames  | 2009-03-27 | default | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | default | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | default | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | default | The only winning move is not to play4. |
    When I run bridgetown build
    Then the output/blog/page-<exist> directory should exist
    And the "output/blog/page-<exist>/index.html" file should exist
    And I should see "<posts>" in "output/blog/page-<exist>/index.html"
    And the "output/blog/page-<not_exist>/index.html" file should not exist

    Examples:
      | exist | posts | not_exist |
      | 2     | 1     | 5         |
      | 3     | 1     | 6         |
      | 4     | 1     | 7         |

  Scenario Outline: Paginate posts with tags
    Given I have a configuration file with:
      | key        | value                              |
      | pagination | { enabled: true, per_page: <num> } |
    And I have a _layouts directory
    And I have an "index.html" page with pagination "{collection: posts, tag: scary}" that contains "{{ paginator.resources.size }} {{ paginator.resources[0].title }}"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | layout  | tags                     | content  |
      | Wargames  | 2009-03-27 | default | strange difficult        | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | default | strange, scary           | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | default | ["awful news", "scary"]  | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | default | terrible; scary          | The only winning move is not to play4. |
    When I run bridgetown build
    Then the output/page/<exist> directory should exist
    And the "output/page/<exist>/index.html" file should exist
    And I should see "<posts>" in "output/page/<exist>/index.html"
    And the "output/page/<not_exist>/index.html" file should not exist

    Examples:
      | num | exist | posts | not_exist | title     |
      | 1   | 3     | 1     | 4         | Wargames2 |
      | 2   | 2     | 2     | 3         | Wargames3 |

  # TODO: this isn't working currently…wondering if it "ever" worked
  Scenario Outline: Setting a custom pagination path with numbered html pages
    Given this scenario should be skipped
    Given I have a configuration file with:
      | key           | value                          |
      | pagination    | { enabled: true, per_page: 1, indexpage: ":num", permalink: "/page/" }              |
      | permalink     | /blog/:year/:month/:day/:title |
    And I have a blog directory
    And I have an "blog/index.html" page with pagination "{enabled: true}" that contains "{{ paginator.documents.size }} {{ paginator.documents[0].title }}"
    And I have an "index.html" page that contains "Don't pick me!"
    And I have a _posts directory
    And I have the following posts:
      | title     | date       | layout  | content                                |
      | Wargames  | 2009-03-27 | default | The only winning move is not to play.  |
      | Wargames2 | 2009-04-27 | default | The only winning move is not to play2. |
      | Wargames3 | 2009-05-27 | default | The only winning move is not to play3. |
      | Wargames4 | 2009-06-27 | default | The only winning move is not to play4. |
    When I run bridgetown build
    And the output/blog/page directory should exist
    And the "output/blog/page/<exist>.html" file should exist
    And I should see "<posts>" in "output/blog/page/<exist>.html"
    And I should see "<title>" in "output/blog/page/<exist>.html"
    And the "output/blog/page/<not_exist>.html" file should not exist

    Examples:
      | exist | posts | not_exist | title     |
      | 2     | 1     | 5         | Wargames2 |
      | 3     | 1     | 6         | Wargames3 |
      | 4     | 1     | 7         | Wargames4 |
