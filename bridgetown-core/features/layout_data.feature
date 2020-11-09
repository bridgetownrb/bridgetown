Feature: Layout data
  As a hacker who likes to avoid repetition
  I want to be able to embed data into my layouts
  In order to make the layouts slightly dynamic

  Scenario: Use custom layout data
    Given I have a _layouts directory
    And I have a "_layouts/custom.html" file with content:
      """
      ---
      foo: my custom data
      ---
      {{ content }} foo: {{ layout.foo }}
      """
    And I have an "index.html" page with layout "custom" that contains "page content"
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "page content\n foo: my custom data" in "output/index.html"
