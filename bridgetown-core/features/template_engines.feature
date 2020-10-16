Feature: Template Engines
  In order to use ERB instead of Liquid
  I want to be able to change the configuration defaults

  Scenario: Rendering a site with default ERB
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= page.data.title %></h1> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | _Luke_, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key                | value |
      | template_engine    | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p><em>Luke</em>, I am your father.</p>" in "output/2009/03/27/star-wars.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars.html"

  Scenario: Rendering a site with default ERB but Liquid template
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.liquid" file that contains "<h1>{{ page.title }}</h1> {{ content }}"
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key                | value |
      | template_engine    | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars.html"

  Scenario: Rendering a site with default ERB but Liquid template via front matter
    Given I have a _layouts directory
    And I have a _posts directory
    And I have an "_layouts/simple.html" file with content:
      """
      ---
      template_engine: liquid
      ---
      <h1>{{ page.title }}</h1> {{ content }}
      """
    And I have the following post:
      | title     | date       | layout | content                 |
      | Star Wars | 2009-03-27 | simple | Luke, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key                | value |
      | template_engine    | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars.html"

  Scenario: Rendering a site with default Liquid but ERB template via front matter
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1>{{ page.title }}</h1> {{ content }}"
    And I have the following post:
      | title     | date       | layout | template_engine | content                 |
      | Star Wars | 2009-03-27 | simple | erb             | Luke, <%= ["I", "am"].join(" ") %> your father. |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars.html"

  Scenario: Rendering an ERB file with custom extension
    Given I have a "data.json" file with content:
      """
      ---
      ---
      <%= jsonify({key: [1, 1+1, 1+1+1]}) %>
      """
    And I have a configuration file with:
      | key                | value |
      | template_engine    | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see the output folder
    And I should see "\{\"key\":\[1,2,3\]\}" in "output/data.json"
