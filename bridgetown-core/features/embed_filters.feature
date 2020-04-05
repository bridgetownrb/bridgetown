Feature: Embed filters
  As a hacker who likes to blog
  I want to be able to transform text inside a post or page
  In order to perform cool stuff in my posts

  Scenario: Convert date to XML schema
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout  | content                                     |
      | Star Wars | 2009-03-27 | default | These aren't the droids you're looking for. |
    And I have a default layout that contains "{{ site.time | date_to_xmlschema }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see today's date in "output/2009/03/27/star-wars.html"

  Scenario: Escape text for XML
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title       | date       | layout  | content                                     |
      | Star & Wars | 2009-03-27 | default | These aren't the droids you're looking for. |
    And I have a default layout that contains "{{ page.title | xml_escape }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Star &amp; Wars" in "output/2009/03/27/star-wars.html"

  Scenario: Calculate number of words
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout  | content                                     |
      | Star Wars | 2009-03-27 | default | These aren't the droids you're looking for. |
    And I have a default layout that contains "{{ content | number_of_words }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "7" in "output/2009/03/27/star-wars.html"

  Scenario: Convert an array into a sentence
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout  | tags                   | content                                     |
      | Star Wars | 2009-03-27 | default | [scifi, movies, force] | These aren't the droids you're looking for. |
    And I have a default layout that contains "{{ page.tags | array_to_sentence_string }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "scifi, movies, and force" in "output/2009/03/27/star-wars.html"

  Scenario: Markdownify a given string
    Given I have a _posts directory
    And I have a _layouts directory
    And I have the following post:
      | title     | date       | layout  | content                                     |
      | Star Wars | 2009-03-27 | default | These aren't the droids you're looking for. |
    And I have a default layout that contains "By {{ '_Obi-wan_' | markdownify }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "By <p><em>Obi-wan</em></p>" in "output/2009/03/27/star-wars.html"

  Scenario: Sort by an arbitrary variable
    Given I have a _layouts directory
    And I have the following page:
      | title  | layout  | value | content   |
      | Page-1 | default | 8     | Something |
    And I have the following page:
      | title  | layout  | value | content   |
      | Page-2 | default | 6     | Something |
    And I have a default layout that contains "{{ site.pages | sort:'value' | map:'title' | join:', ' }}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see exactly "Page-2, Page-1" in "output/page-1.html"
    And I should see exactly "Page-2, Page-1" in "output/page-2.html"

  Scenario: Sort pages by the title
    Given I have a _layouts directory
    And I have the following pages:
      | title | layout  | content |
      | Dog   | default | Run     |
      | Bird  | default | Fly     |
    And I have the following page:
      | layout  | content |
      | default | Jump    |
    And I have a default layout that contains "{% assign sorted_pages = site.pages | sort: 'title' %}The rule of {{ sorted_pages.size }}: {% for p in sorted_pages %}{{ p.content | strip_html | strip_newlines }}, {% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see exactly "The rule of 3: Jump, Fly, Run," in "output/bird.html"

  Scenario: Sort pages by the title ordering pages without title last
    Given I have a _layouts directory
    And I have the following pages:
      | title | layout  | content |
      | Dog   | default | Run     |
      | Bird  | default | Fly     |
    And I have the following page:
      | layout  | content |
      | default | Jump    |
    And I have a default layout that contains "{% assign sorted_pages = site.pages | sort: 'title', 'last' %}The rule of {{ sorted_pages.size }}: {% for p in sorted_pages %}{{ p.content | strip_html | strip_newlines }}, {% endfor %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see exactly "The rule of 3: Fly, Run, Jump," in "output/bird.html"

  Scenario: Filter posts by given property and value
    Given I have a _posts directory
    And I have the following posts:
      | title    | date       | content   | property                  |
      | Bird     | 2019-03-13 | Chirp     | [nature, sounds]          |
      | Cat      | 2019-03-14 | Meow      | [sounds]                  |
      | Dog      | 2019-03-15 | Bark      |                           |
      | Elephant | 2019-03-16 | Asiatic   | wildlife                  |
      | Goat     | 2019-03-17 | Mountains | ""                        |
      | Horse    | 2019-03-18 | Mustang   | []                        |
      | Iguana   | 2019-03-19 | Reptile   | {}                        |
      | Jaguar   | 2019-03-20 | Reptile   | {foo: lorem, bar: nature} |
    And I have a "string-value.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', 'wildlife' %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    And I have a "string-value-array.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', 'sounds' %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    And I have a "string-value-hash.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', 'nature' %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    And I have a "nil-value.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', nil %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    And I have an "empty-liquid-literal.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', empty %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    And I have a "blank-liquid-literal.md" page with content:
      """
      {% assign pool = site.posts | reverse | where: 'property', blank %}
      {{ pool | map: 'title' | join: ', ' }}
      """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see exactly "<p>Elephant</p>" in "output/string-value.html"
    And I should see exactly "<p>Bird, Cat</p>" in "output/string-value-array.html"
    And I should see exactly "<p>Bird</p>" in "output/string-value-hash.html"
    And I should see exactly "<p>Dog</p>" in "output/nil-value.html"
    And I should see exactly "<p>Dog, Goat, Horse, Iguana</p>" in "output/empty-liquid-literal.html"
    And I should see exactly "<p>Dog, Goat, Horse, Iguana</p>" in "output/blank-liquid-literal.html"
