Feature: Site data
  As a hacker who likes to blog
  I want to be able to embed data into my site
  In order to make the site slightly dynamic

  Scenario: Use page variable in a page
    Given I have an "contact.html" page with title "Contact" that contains "{{ page.title }}: email@example.com"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Contact: email@example.com" in "output/contact/index.html"

  Scenario: Use site.time variable
    Given I have an "index.html" page that contains "{{ site.time }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see today's time in "output/index.html"

  Scenario: Use site.posts variable for latest post
    Given I have a _posts directory
    And I have an "index.html" page that contains "{{ collections.posts.resources.first.title }}: {{ collections.posts.resources.first.relative_url }}"
    And I have the following posts:
      | title       | date       | content        |
      | First Post  | 2009-03-25 | My First Post  |
      | Second Post | 2009-03-26 | My Second Post |
      | Third Post  | 2009-03-27 | My Third Post  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Third Post: /2009/03/27/third-post/" in "output/index.html"

  Scenario: Use site.posts variable in a loop
    Given I have a _posts directory
    And I have an "index.html" page that contains "{% for post in collections.posts.resources %} {{ post.title }} {% endfor %}"
    And I have the following posts:
      | title       | date       | content        |
      | First Post  | 2009-03-25 | My First Post  |
      | Second Post | 2009-03-26 | My Second Post |
      | Third Post  | 2009-03-27 | My Third Post  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Third Post  Second Post  First Post" in "output/index.html"

  Scenario: Use site.categories.code variable
    Given I have a _posts directory
    And I have an "index.html" page that contains "{% for post in site.categories.code %} {{ post.title }} {% endfor %}"
    And I have the following posts:
      | title          | date       | category | content            |
      | Awesome Hack   | 2009-03-26 | code     | puts 'Hello World' |
      | Delicious Beer | 2009-03-26 | food     | 1) Yuengling       |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Awesome Hack" in "output/index.html"

  Scenario: Use site.tags variable
    Given I have a _posts directory
    And I have an "index.html" page that contains "{% for post in site.tags.beer %} {{ post.content }} {% endfor %}"
    And I have the following posts:
      | title          | date       | tag  | content      |
      | Delicious Beer | 2009-03-26 | beer | 1) Yuengling |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Yuengling" in "output/index.html"

  Scenario: Order Posts by name when on the same date
  Given I have a _posts directory
  And I have an "index.html" page that contains "{% for post in collections.posts.resources %}{{ post.title }}:{{ post.previous.title}},{{ post.next.title}} {% endfor %}"
  And I have the following posts:
    | title | date       | content |
    | first | 2009-02-26 | first   |
    | A     | 2009-03-26 | A       |
    | B     | 2009-03-26 | B       |
    | C     | 2009-03-26 | C       |
    | last  | 2009-04-26 | last    |
  When I run bridgetown build
  Then I should get a zero exit status
    And the output directory should exist
  And I should see "last:,C C:last,B B:C,A A:B,first first:A," in "output/index.html"

  Scenario: Use configuration date in site payload
    Given I have an "index.html" page that contains "{{ site.url }}"
    And I have a configuration file with "url" set to "http://example.com"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "http://example.com" in "output/index.html"

  Scenario: Access Bridgetown version via bridgetown.version
    Given I have an "index.html" page that contains "{{ bridgetown.version }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "\d+\.\d+\.\d+" in "output/index.html"
