Feature: Cache
  As a developer who likes to create plugins
  I want to be able to cache certain aspects across multiple builds
  And retrieve the cached aspects when needed

  Scenario: Default Cache directory
    Given I have an "index.md" page that contains "{{ site.title }}"
    And I have a configuration file with "title" set to "Hello World"
    When I run bridgetown build
    Then I should get a zero exit status
    And the src/.bridgetown-cache directory should exist
    And the src/.bridgetown-cache/Bridgetown/Cache/Bridgetown--Cache directory should exist
    And the output directory should exist
    And I should see "<p>Hello World</p>" in "output/index.html"

  Scenario: Custom Cache directory
    Given I have an "index.md" page that contains "{{ site.title }}"
    And I have a configuration file with:
      | key       | value       |
      | title     | Hello World |
      | cache_dir | .foo-cache  |
    When I run bridgetown build
    Then I should get a zero exit status
    And the src/.foo-cache directory should exist
    And the src/.foo-cache/Bridgetown/Cache/Bridgetown--Cache directory should exist
    But the src/.bridgetown-cache directory should not exist
    And the output directory should exist
    And I should see "<p>Hello World</p>" in "output/index.html"

  Scenario: Disabling disk usage
    Given I have an "index.md" page that contains "{{ site.title }}"
    And I have a configuration file with "title" set to "Hello World"
    When I run bridgetown build --disable-disk-cache
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<p>Hello World</p>" in "output/index.html"
    But the src/.bridgetown-cache directory should not exist
