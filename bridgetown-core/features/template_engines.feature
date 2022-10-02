Feature: Template Engines
  In order to use ERB instead of Liquid
  I want to be able to change the configuration defaults

  Scenario: Rendering a site with default ERB
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= page.data.title %></h1> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | content                                           |
      | Star Wars | 2009-03-27 | simple | _Luke_, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p><em>Luke</em>, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering a site with default ERB but Liquid layout
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.liquid" file that contains "<h1>{{ page.title }}</h1> {{ content }}"
    And I have the following post:
      | title     | date       | layout | content                                         |
      | Star Wars | 2009-03-27 | simple | Luke, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering a site with default ERB but Liquid page
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= page.data.title %></h1> <%= page.data.template_engine %> <%= yield %>"
    And I have a "liquidpage.liquid" file with content:
      """
      ---
      title: Star Wars
      layout: simple
      ---
      Luke, {{ "I,am" | split: "," | join: " " }} your <%= 'father'.upcase %>.
      """
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "Luke, I am your <%= 'father'.upcase %>." in "output/liquidpage/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/liquidpage/index.html"

  Scenario: Rendering a site with default ERB but Liquid layout via front matter
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
      | title     | date       | layout | content                                         |
      | Star Wars | 2009-03-27 | simple | Luke, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering a site with default Liquid but ERB template via front matter
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1>{{ page.title }}</h1> {{ content }}"
    And I have the following post:
      | title     | date       | layout | template_engine | content                                         |
      | Star Wars | 2009-03-27 | simple | erb             | Luke, <%= ["I", "am"].join(" ") %> your father. |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p>Luke, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering an ERB file with custom extension
    Given I have a "data.json" file with content:
      """
      ---
      ---
      <%= raw jsonify({key: [1, 1+1, 1+1+1]}) %>
      """
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see the output folder
    And I should see "\{\"key\":\[1,2,3\]\}" in "output/data.json"

  Scenario: Rendering a site with default ERB but file template engine is none
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= page.data.title %></h1> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | template_engine | content                                           |
      | Star Wars | 2009-03-27 | simple | none            | _Luke_, <%= ["I", "am"].join(" ") %> your father. |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p><em>Luke</em>, &lt;%= " in "output/2009/03/27/star-wars/index.html"
    And I should see ".join" in "output/2009/03/27/star-wars/index.html"
    And I should see " %&gt; your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering slotted content
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= page.data.title %> <%= slotted :subtitle, "[BLANK]" %></h1> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | content                                           |
      | Star Wars | 2009-03-27 | simple | _Luke_, <%= ["I", "am"].join(" ") %> your father<% slot :subtitle, "V: ", transform: false %><% slot :subtitle, "The Empire Strikes Back", transform: false %>. |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<p><em>Luke</em>, I am your father.</p>" in "output/2009/03/27/star-wars/index.html"
    And I should see "<h1>Star Wars V: The Empire Strikes Back</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Rendering default slotted content
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<h1><%= data.title %>: <%= slotted :subtitle, "[BLANK]" %></h1> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | content                                           |
      | Star Wars | 2009-03-27 | simple | What a piece of junk! |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<h1>Star Wars: \[BLANK\]</h1>" in "output/2009/03/27/star-wars/index.html"

  Scenario: Replacing slotted content
    Given I have a _layouts directory
    And I have a _posts directory
    And I have a "_layouts/simple.html" file that contains "<%= slotted :title, "[BLANK]" %> <%= yield %>"
    And I have the following post:
      | title     | date       | layout | content                                           |
      | Star Wars | 2009-03-27 | simple | <% slot "title" do %># Star Trek<% end %><% slot "title", replace: true do %> # Star Wars<% end %> |
    And I have a configuration file with:
      | key             | value |
      | template_engine | erb   |
    When I run bridgetown build
    Then I should get a zero exit status
    And I should see "<h1 id=\"star-wars\">Star Wars</h1>" in "output/2009/03/27/star-wars/index.html"