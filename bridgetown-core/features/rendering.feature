Feature: Rendering
  As a hacker who likes to blog
  I want to be able to make a static site
  In order to share my awesome ideas with the interwebs
  But I want to make it as simply as possible
  So render with Liquid and place in Layouts

  Scenario: Rendering a site with parentheses in its path name
    Given I have a blank site in "src/omega(beta)"
    And   I have an "omega(beta)/test.md" page with layout "simple" that contains "Hello World"
    And   I have an omega(beta)/_includes directory
    And   I have an "omega(beta)/_includes/head.html" file that contains "Snippet"
    And   I have a configuration file with "source" set to "src/omega(beta)"
    And   I have an omega(beta)/_layouts directory
    And   I have an "omega(beta)/_layouts/simple.html" file that contains "{% include head.html %}: {{ content }}"
    When  I run bridgetown build --profile
    Then  I should get a zero exit status
    And   I should see "Snippet: <p>Hello World</p>" in "output/test.html"
    And   I should see "_layouts/simple.html" in the build output

  Scenario: When receiving bad Liquid
    Given I have a "index.html" page with layout "simple" that contains "{% include invalid.html %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid Exception" in the build output

  Scenario: When receiving a liquid syntax error in included file
    Given I have a _includes directory
    And   I have a "_includes/invalid.html" file that contains "{% INVALID %}"
    And   I have a "index.html" page with layout "simple" that contains "{% include invalid.html %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid Exception: Liquid syntax error \(.+/invalid\.html line 1\): Unknown tag 'INVALID' included in index\.html" in the build output

  Scenario: When receiving a generic liquid error in included file
    Given I have a _includes directory
    And   I have a "_includes/invalid.html" file that contains "{{ site.title | prepend 'Prepended Text' }}"
    And   I have a "index.html" page with layout "simple" that contains "{% include invalid.html %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid Exception: Liquid error \(.+/_includes/invalid\.html line 1\): wrong number of arguments (\(given 1, expected 2\)|\(1 for 2\)) included in index\.html" in the build output

  Scenario: Rendering a default site containing a file with rogue Liquid constructs
    Given I have a "index.html" page with title "Simple Test" that contains "{{ page.title | foobar }}\n\n{{ page.author }}"
    When  I run bridgetown build
    Then  I should get a zero exit-status
    And   I should not see "Liquid Exception:" in the build output

  Scenario: Rendering a custom site containing a file with a non-existent Liquid variable
    Given I have a "index.html" file with content:
    """
    ---
    title: Simple Test
    ---
    {{ page.title }}

    {{ page.author }}
    """
    And   I have a "bridgetown.config.yml" file with content:
    """
    liquid:
      strict_variables: true
    """
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid error \(line 3\): undefined variable author in index.html" in the build output

  Scenario: Rendering a custom site containing a file with a non-existent Liquid filter
    Given I have a "index.html" file with content:
    """
    ---
    author: John Doe
    ---
    {{ page.title }}

    {{ page.author | foobar }}
    """
    And   I have a "bridgetown.config.yml" file with content:
    """
    liquid:
      strict_filters: true
    """
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid error \(line 3\): undefined filter foobar in index.html" in the build output

  Scenario: Render Liquid and place in layout
    Given I have a "index.html" page with layout "simple" that contains "Hi there, Bridgetown {{ bridgetown.environment }}!"
    And I have a simple layout that contains "{{ content }}Ahoy, indeed!"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Hi there, Bridgetown development!\nAhoy, indeed" in "output/index.html"

  Scenario: Ignore defaults and don't place pages and documents with layout set to 'none'
    Given I have a "index.md" page with layout "none" that contains "Hi there, {{ site.author }}!"
    And I have a _trials directory
    And I have a "_trials/no-layout.md" page with layout "none" that contains "Hi there, {{ site.author }}!"
    And I have a "_trials/test.md" page with layout "null" that contains "Hi there, {{ site.author }}!"
    And I have a none layout that contains "{{ content }}Welcome!"
    And I have a page layout that contains "{{ content }}Check this out!"
    And I have a configuration file with:
    | key             | value                                          |
    | author          | John Doe                                       |
    | collections     | {trials: {output: true}}                       |
    | defaults        | [{scope: {path: ""}, values: {layout: page}}]  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should not see "Welcome!" in "output/trials/no-layout.html"
    And I should not see "Check this out!" in "output/trials/no-layout.html"
    But I should see "Check this out!" in "output/trials/test.html"
    And I should see "Hi there, John Doe!" in "output/index.html"
    And I should not see "Welcome!" in "output/index.html"
    And I should not see "Build Warning:" in the build output

  Scenario: Don't place pages and documents with layout set to 'none'
    Given I have a "index.md" page with layout "none" that contains "Hi there, {{ site.author }}!"
    And I have a _trials directory
    And I have a "_trials/no-layout.md" page with layout "none" that contains "Hi there, {{ site.author }}!"
    And I have a "_trials/test.md" page with layout "page" that contains "Hi there, {{ site.author }}!"
    And I have a none layout that contains "{{ content }}Welcome!"
    And I have a page layout that contains "{{ content }}Check this out!"
    And I have a configuration file with:
    | key             | value                     |
    | author          | John Doe                  |
    | collections     | {trials: {output: true}}  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should not see "Welcome!" in "output/trials/no-layout.html"
    And I should not see "Welcome!" in "output/index.html"
    But I should see "Check this out!" in "output/trials/test.html"
    And I should see "Hi there, John Doe!" in "output/index.html"
    And I should not see "Build Warning:" in the build output

  Scenario: Execute inline Ruby if ENV is set
    Given I have a _posts directory
    And I have the following post:
      | title  | date | layout  | cool | content |
      | Page   | 2020-01-01 | simple  | !ruby/string:Rb \|\n  "Very" + " Cool".upcase | Something {{ page.cool }} |
    And I have a "index.html" page with layout "simple" that contains "{% for post in site.posts %}{{ post.content }}{% endfor %}"
    And I have a simple layout that contains "{{ content }}"
    And I have a configuration file with "inline_ruby_in_front_matter" set to "true"
    And I have an env var BRIDGETOWN_EXECUTE_RUBY_FRONT_MATTER set to true
    When I run bridgetown build
    And I delete the env var BRIDGETOWN_EXECUTE_RUBY_FRONT_MATTER
    Then I should see "Very COOL" in "output/index.html"

  Scenario: Don't execute inline Ruby if ENV is not set
    Given I have a _posts directory
    And I have the following post:
      | title  | date | layout  | cool | content |
      | Page   | 2020-01-01 | simple  | !ruby/string:Rb \|\n  "Very" + " Cool".upcase | Something {{ page.cool }} |
    And I have a "index.html" page with layout "simple" that contains "{% for post in site.posts %}{{ post.content }}{% endfor %}"
    And I have a simple layout that contains "{{ content }}"
    And I have a configuration file with "inline_ruby_in_front_matter" set to "true"
    When I run bridgetown build
    Then I should not see "Very COOL" in "output/index.html"

  Scenario: Execute nested inline Ruby
    Given I have a _posts directory
    And I have the following post:
      | title  | date | layout  | cool | content |
      | Page   | 2020-01-01 | simple  | #\n  nested_cool: !ruby/string:Rb \|\n    "Very Very" + " Cool".upcase | Something {{ page.cool.nested_cool }} |
    And I have a "index.html" page with layout "simple" that contains "{% for post in site.posts %}{{ post.content }}{% endfor %}"
    And I have a simple layout that contains "{{ content }}"
    And I have a configuration file with "inline_ruby_in_front_matter" set to "true"
    And I have an env var BRIDGETOWN_EXECUTE_RUBY_FRONT_MATTER set to true
    When I run bridgetown build
    And I delete the env var BRIDGETOWN_EXECUTE_RUBY_FRONT_MATTER
    Then I should see "Very Very COOL" in "output/index.html"
