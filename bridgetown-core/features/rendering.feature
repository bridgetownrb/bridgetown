Feature: Rendering
  As a hacker who likes to blog
  I want to be able to make a static site
  In order to share my awesome ideas with the interwebs
  But I want to make it as simply as possible
  So render with Liquid and place in Layouts

  Scenario: Rendering a site with page/resource data
    Given I have an "index.html" file with content:
    """
    ---
    layout: simple
    author: John Doe
    ---
    """
    And I have a simple layout that contains "{{ page.author }}:{{ resource.author }}:{{ resource.data.author }}"
    When I run bridgetown build
    Then I should see "John Doe:John Doe:John Doe" in "output/index.html"

  Scenario: Rendering a site with parentheses in its path name
    Given I have a blank site in "src/omega(beta)"
    And   I have an "omega(beta)/test.md" page with layout "simple" that contains "Hello World"
    And   I have an omega(beta)/_components directory
    And   I have an "omega(beta)/_components/head.html" file that contains "Snippet"
    And   I have a configuration file with "source" set to "src/omega(beta)"
    And   I have an omega(beta)/_layouts directory
    And   I have an "omega(beta)/_layouts/simple.html" file that contains "{% render 'head' %}: {{ content }}"
    When  I run bridgetown build --profile
    Then  I should get a zero exit status
    And   I should see "Snippet: <p>Hello World</p>" in "output/test/index.html"
    And   I should see "_layouts/simple.html" in the build output

  Scenario: When receiving bad Liquid
    Given I have a "index.html" page with layout "simple" that contains "{% BLAH %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid Exception" in the build output

  Scenario: When receiving a liquid syntax error in included file
    Given I have a _components directory
    And   I have a "_components/invalid.liquid" file that contains "{% INVALID %}"
    And   I have a "index.html" page with layout "simple" that contains "{% render 'invalid' %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid syntax error \(line 1\): Unknown tag 'INVALID'" in the build output

  Scenario: When receiving a generic liquid error in included file
    Given I have a _components directory
    And   I have a "_components/invalid.liquid" file that contains "{{ site.title | prepend 'Prepended Text' }}"
    And   I have a "index.html" page with layout "simple" that contains "{% render 'invalid' %}"
    And   I have a simple layout that contains "{{ content }}"
    When  I run bridgetown build
    Then  I should get a non-zero exit-status
    And   I should see "Liquid error \(invalid line 1\): wrong number of arguments (\(given 1, expected 2\)|\(1 for 2\))" in the build output

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
    And   I should see "Liquid error \(line 3\): undefined variable author" in the build output

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
    And   I should see "Liquid error \(line 3\): undefined filter foobar" in the build output

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
    And I have a "_trials/false-layout.md" page with layout "false" that contains "Hi there, {{ site.author }}!"
    And I have a "_trials/test.md" page with layout "null" that contains "Hi there, {{ site.author }}!"
    And I have a none layout that contains "{{ content }}Welcome!"
    And I have a page layout that contains "{{ content }}Check this out!"
    And I have a configuration file with:
    | key             | value                                          |
    | author          | John Doe                                       |
    | collections     | {trials: {output: true}}                       |
    | defaults        | [{scope: {collection: "trials"}, values: {layout: page}}]  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should not see "Welcome!" in "output/trials/no-layout/index.html"
    And I should not see "Check this out!" in "output/trials/no-layout/index.html"
    And I should not see "Check this out!" in "output/trials/false-layout/index.html"
    # TODO: not sure why this isn't working!
#    But I should see "Check this out!" in "output/trials/test/index.html"
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
    And I should not see "Welcome!" in "output/trials/no-layout/index.html"
    And I should not see "Welcome!" in "output/index.html"
    But I should see "Check this out!" in "output/trials/test/index.html"
    And I should see "Hi there, John Doe!" in "output/index.html"
    And I should not see "Build Warning:" in the build output
