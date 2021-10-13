Feature: Post data
  As a hacker who likes to blog
  I want to be able to embed data into my posts
  In order to make the posts slightly dynamic

  Scenario: Use post.title variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, I am your father. |
    And I have a simple layout that contains "Post title: {{ page.title }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post title: Star Wars" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.url variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, I am your father. |
    And I have a simple layout that contains "Post url: {{ page.relative_url }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post url: /2009/03/27/star-wars/" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.date variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, I am your father. |
    And I have a simple layout that contains "Post date: {{ page.date | date_to_string }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post date: 27 Mar 2009" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.date variable with invalid
    Given I have a _posts directory
    And I have a "_posts/2016-01-01-test.md" page with date "tuesday" that contains "I have a bad date."
    When I run bridgetown build
    Then the output directory should not exist
    And I should see "Resource '_posts/2016-01-01-test.md' does not have a valid date." in the build output

  Scenario: Invalid date in filename
    Given I have a _posts directory
    And I have a "_posts/2016-22-01-test.md" page that contains "I have a bad date."
    When I run bridgetown build
    Then the output directory should not exist
    And I should see "Resource '_posts/2016-22-01-test.md' does not have a valid date." in the build output

  Scenario: Use post.id variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, I am your father. |
    And I have a simple layout that contains "Post id: {{ page.id }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post id: repo://posts.collection/_posts/2009-03-27-star-wars.markdown" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.content variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, I am your father. |
    And I have a simple layout that contains "Post content: {{ content }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post content: <p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.tags variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | tag   | content                 |
      | Star Wars | 2009-05-18 | simple | twist | Luke, I am your father. |
    And I have a simple layout that contains "Post tags: {{ page.tags }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post tags: twist" in "output/2009/05/18/star-wars/index.html"

  Scenario: Use post.categories variable when category is in YAML
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | category | content                 |
      | Star Wars | 2009-03-27 | simple | movies   | Luke, I am your father. |
    And I have a simple layout that contains "Post category: {{ page.categories }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post category: movies" in "output/movies/2009/03/27/star-wars/index.html"

  Scenario: Use post.categories variable when category is in YAML and is mixed-case
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | category | content                 |
      | Star Wars | 2009-03-27 | simple | Movies   | Luke, I am your father. |
    And I have a simple layout that contains "Post category: {{ page.categories }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post category: Movies" in "output/movies/2009/03/27/star-wars/index.html"

  Scenario: Use post.categories variable when categories are in YAML
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | categories          | content                 |
      | Star Wars | 2009-03-27 | simple | ['scifi', 'movies'] | Luke, I am your father. |
    And I have a simple layout that contains "Post categories: {{ page.categories | array_to_sentence_string }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post categories: scifi and movies" in "output/scifi/movies/2009/03/27/star-wars/index.html"

  Scenario: Use post.categories variable when categories are in YAML and are duplicated
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | categories           | content                 |
      | Star Wars | 2009-03-27 | simple | ['movies', 'movies'] | Luke, I am your father. |
    And I have a simple layout that contains "Post category: {{ page.categories }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post category: movies" in "output/movies/2009/03/27/star-wars/index.html"

  Scenario: Subdirectories of _posts not applied to post.categories
    Given I have a _posts/scifi directory
    And I have a "_posts/scifi/2009-03-27-star-wars.html" page with layout "simple" that contains "hi"
    And I have a _layouts directory
    And I have a simple layout that contains "Post category: {{ page.categories }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should not see "Post category: movies" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use post.categories variable when categories are in YAML with mixed case
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following posts:
      | title     | date       | layout | categories          | content                     |
      | Star Wars | 2009-03-27 | simple | ['scifi', 'Movies'] | Luke, I am your father.     |
      | Star Trek | 2013-03-17 | simple | ['SciFi', 'movies'] | Jean Luc, I am your father. |
    And I have a simple layout that contains "Post categories: {{ page.categories | array_to_sentence_string }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post categories: scifi and Movies" in "output/scifi/movies/2009/03/27/star-wars/index.html"
    And I should see "Post categories: SciFi and movies" in "output/scifi/movies/2013/03/17/star-trek/index.html"

Scenario: Use page.render_with_liquid variable
  Given I have a _posts directory
  And I have the following posts:
    | title           | render_with_liquid | date       | content                |
    | Unrendered Post | false              | 2017-07-06 | Hello {{ page.title }} |
    | Rendered Post   | true               | 2017-07-06 | Hello {{ page.title }} |
  When I run bridgetown build
  Then I should get a zero exit status
  And the output directory should exist
  And I should not see "Hello Unrendered Post" in "output/2017/07/06/unrendered-post/index.html"
  But I should see "Hello {{ page.title }}" in "output/2017/07/06/unrendered-post/index.html"
  And I should see "Hello Rendered Post" in "output/2017/07/06/rendered-post/index.html"

  Scenario: Cannot override page.path variable
    Given I have a _posts directory
    And I have the following post:
      | title    | date       | path               | content                      |
      | override | 2013-04-12 | override-path.html | Non-custom path: {{ page.path }} |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "/src/_posts/2013-04-12-override.markdown" in "output/2013/04/12/override/index.html"

  Scenario: Disable a post from being published
    Given I have a _posts directory
    And I have an "index.html" file that contains "Published!"
    And I have the following post:
      | title     | date       | layout | published | content                 |
      | Star Wars | 2009-03-27 | simple | false     | Luke, I am your father. |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/2009/03/27/star-wars/index.html" file should not exist
    And I should see "Published!" in "output/index.html"

  Scenario: Use a custom variable
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout | author      | content                 |
      | Star Wars | 2009-03-27 | simple | Darth Vader | Luke, I am your father. |
    And I have a simple layout that contains "Post author: {{ page.author }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Post author: Darth Vader" in "output/2009/03/27/star-wars/index.html"

  Scenario: Use a variable which is a reserved keyword in Ruby
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title   | date       | layout | class     | content                 |
      | My post | 2016-01-21 | simple | kewl-post | Luke, I am your father. |
    And I have a simple layout that contains "{{page.title}} has class {{page.class}}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "My post has class kewl-post" in "output/2016/01/21/my-post/index.html"

  Scenario: Previous and next posts title
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following posts:
      | title            | date       | layout  | author      | content                 |
      | Star Wars        | 2009-03-27 | ordered | Darth Vader | Luke, I am your father. |
      | Some like it hot | 2009-04-27 | ordered | Osgood      | Nobody is perfect.      |
      | Terminator       | 2009-05-27 | ordered | Arnold      | Sayonara, baby          |
    And I have a ordered layout that contains "Previous post: {{ page.previous.title }} and next post: {{ page.next.title }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Previous post: Some like it hot" in "output/2009/03/27/star-wars/index.html"
    And I should see "next post: Some like it hot" in "output/2009/05/27/terminator/index.html"
