Feature: Site configuration
  As a hacker who likes to blog
  I want to be able to configure bridgetown
  In order to make setting up a site easier

  Scenario: Change source directory
    Given I have a blank site in "src/_sourcedir"
    And I have an "_sourcedir/index.html" file that contains "Changing source directory"
    And I have a configuration file with "source" set to "src/_sourcedir"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Changing source directory" in "output/index.html"

  Scenario: Change destination directory
    Given I have an "index.html" file that contains "Changing destination directory"
    And I have a configuration file with "destination" set to "_mysite"
    When I run bridgetown build
    Then the _mysite directory should exist
    And I should see "Changing destination directory" in "_mysite/index.html"

  Scenario Outline: Similarly named source and destination
    Given I have a blank site in "<source>"
    And I have a "<source>/index.md" page that contains "markdown"
    And I have a configuration file with:
    | key         | value    |
    | source      | <source> |
    | destination | <dest>   |
    When I run bridgetown build
    Then the <source> directory should exist
    And the "<dest>/index.html" file should <file_exist> exist
    And I should see "markdown" in "<source>/index.md"

    Examples:
      | source         | dest         | file_exist |
      | srcsite_source | srcsite      |            |
      | srcsite        | srcsite_dest |            |
      | srcsite/       | srcsite      | not        |
      | srcsite        | ./srcsite    | not        |
      | srcsite/source | srcsite      | not        |
      | srcsite        | srcsite/dest |            |

  Scenario: Exclude files inline
    Given I have an "Rakefile" file that contains "I want to be excluded"
    And I have an "README" file that contains "I want to be excluded"
    And I have an "index.html" file that contains "I want to be included"
    And I have a "Gemfile" file that contains "gem 'include-me'"
    And I have a configuration file with "exclude" set to "['Rakefile', 'README']"
    When I run bridgetown build
    Then I should see "I want to be included" in "output/index.html"
    And the "output/Gemfile" file should not exist
    And the "output/Rakefile" file should not exist
    And the "output/README" file should not exist

  Scenario: Exclude files with YAML array
    Given I have an "Rakefile" file that contains "I want to be excluded"
    And I have an "README" file that contains "I want to be excluded"
    And I have an "index.html" file that contains "I want to be included"
    And I have a "Gemfile" file that contains "gem 'include-me'"
    And I have a configuration file with "exclude" set to:
      | value    |
      | README   |
      | Rakefile |
    When I run bridgetown build
    Then I should see "I want to be included" in "output/index.html"
    And the "output/Rakefile" file should not exist
    And the "output/README" file should not exist
    And the "output/Gemfile" file should not exist

  Scenario: Copy over excluded files when their directory is explicitly included
    Given I have a ".gitignore" file that contains ".DS_Store"
    And I have an ".htaccess" file that contains "SomeDirective"
    And I have a "Gemfile" file that contains "gem 'include-me'"
    And I have a node_modules directory
    And I have a "node_modules/bazinga.js" file that contains "var c = 'Bazinga!';"
    And I have a "node_modules/warning.js" file that contains "var w = 'Winter is coming!';"
    And I have a configuration file with "include" set to:
      | value        |
      | .gitignore   |
      | .foo         |
      | Gemfile      |
      | node_modules |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/.htaccess" file should not exist
    But I should see ".DS_Store" in "output/.gitignore"
    And I should see "gem 'include-me'" in "output/Gemfile"
    And I should see "var c = 'Bazinga!';" in "output/node_modules/bazinga.js"
    And I should see "var w = 'Winter is coming!';" in "output/node_modules/warning.js"

  Scenario: Copy over excluded files only when they are explicitly included
    Given I have a ".gitignore" file that contains ".DS_Store"
    And I have an ".htaccess" file that contains "SomeDirective"
    And I have a node_modules directory
    And I have a "node_modules/bazinga.js" file that contains "var c = 'Bazinga!';"
    And I have a "node_modules/warning.js" file that contains "var w = 'Winter is coming!';"
    And I have a configuration file with "include" set to:
      | value                   |
      | .gitignore              |
      | .foo                    |
      | node_modules/bazinga.js |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/.htaccess" file should not exist
    But I should see ".DS_Store" in "output/.gitignore"
    And I should see "var c = 'Bazinga!';" in "output/node_modules/bazinga.js"
    But the "output/node_modules/warning.js" file should not exist

  Scenario: Copy over excluded wild-card files only when they are explicitly included
    Given I have a ".gitignore" file that contains ".DS_Store"
    And I have an ".htaccess" file that contains "SomeDirective"
    And I have an "foo.txt" file that contains "Lorem Ipsum"
    And I have an "index.md" page that contains "{{ site.title }}"
    And I have an "about.md" page that contains "{{ site.author }}"
    And I have a configuration file with:
      | key      | value        |
      | title    | Barren Site  |
      | author   | John Doe     |
      | exclude  | ["**"]       |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/.gitignore" file should not exist
    And the "output/foo.txt" file should not exist
    And the "output/index.html" file should not exist
    And the "output/about.html" file should not exist
    But the "output/.htaccess" file should exist
    Given I have a configuration file with:
      | key      | value        |
      | title    | Barren Site  |
      | author   | John Doe     |
      | exclude  | ["**"]       |
      | include  | ["about.md"] |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/.gitignore" file should not exist
    And the "output/foo.txt" file should not exist
    And the "output/index.html" file should not exist
    And the "output/.htaccess" file should not exist
    But the "output/about/index.html" file should exist
    And I should see "John Doe" in "output/about/index.html"

  Scenario: Use Kramdown for markup
    Given I have an "index.markdown" page that contains "[Google](https://www.google.com)"
    And I have a configuration file with "markdown" set to "kramdown"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<a href=\"https://www.google.com\">Google</a>" in "output/index.html"

  Scenario: Highlight code with rouge
    Given I have an "index.html" page that contains "{% highlight ruby %} puts 'Hello world!' {% endhighlight %}"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Hello world!" in "output/index.html"
    And I should see "class=\"highlight\"" in "output/index.html"

  Scenario: Set time and no future dated posts
    Given I have a _layouts directory
    And I have a page layout that contains "Page Layout: {{ collections.posts.resources.size }} on {{ site.time | date: "%Y-%m-%d" }}"
    And I have a post layout that contains "Post Layout: {{ content }}"
    And I have an "index.html" page with layout "page" that contains "site index page"
    And I have a configuration file with:
      | key         | value        |
      | time        | 2010-01-01   |
      | future      | false        |
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content             |
      | entry1 | 2007-12-31 | post   | content for entry1. |
      | entry2 | 2020-01-31 | post   | content for entry2. |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Page Layout: 1 on 2010-01-01" in "output/index.html"
    And I should see "Post Layout: <p>content for entry1.</p>" in "output/2007/12/31/entry1/index.html"
    And the "output/2020/01/31/entry2/index.html" file should not exist

  Scenario: Set time and future dated posts allowed
    Given I have a _layouts directory
    And I have a page layout that contains "Page Layout: {{ collections.posts.resources.size }} on {{ site.time | date: "%Y-%m-%d" }}"
    And I have a post layout that contains "Post Layout: {{ content }}"
    And I have an "index.html" page with layout "page" that contains "site index page"
    And I have a configuration file with:
      | key         | value        |
      | time        | 2010-01-01   |
      | future      | true         |
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content             |
      | entry1 | 2007-12-31 | post   | content for entry1. |
      | entry2 | 2020-01-31 | post   | content for entry2. |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Page Layout: 2 on 2010-01-01" in "output/index.html"
    And I should see "Post Layout: <p>content for entry1.</p>" in "output/2007/12/31/entry1/index.html"
    And I should see "Post Layout: <p>content for entry2.</p>" in "output/2020/01/31/entry2/index.html"

    Scenario: Generate proper dates with explicitly set timezone (same as posts' time)
      Given I have a _layouts directory
      And I have a page layout that contains "Page Layout: {{ collections.posts.resources.size }}"
      And I have a post layout that contains "Post Layout: {{ content }} built at {{ page.date | date_to_xmlschema }}"
      And I have an "index.html" page with layout "page" that contains "site index page"
      And I have a configuration file with:
        | key         | value            |
        | timezone    | America/New_York |
      And I have a _posts directory
      And I have the following posts:
        | title     | date                   | layout  | content             |
        | entry1    | 2013-04-09 23:22 -0400 | post    | content for entry1. |
        | entry2    | 2013-04-10 03:14 -0400 | post    | content for entry2. |
      When I run bridgetown build
      Then I should get a zero exit status
      And the output directory should exist
      And I should see "Page Layout: 2" in "output/index.html"
      And I should see "Post Layout: <p>content for entry1.</p>\n built at" in "output/2013/04/09/entry1/index.html"
      And I should see "Post Layout: <p>content for entry2.</p>\n built at" in "output/2013/04/10/entry2/index.html"
      And I should see "2013-04-09T23:22:00-04:00" in "output/2013/04/09/entry1/index.html"
      And I should see "2013-04-10T03:14:00-04:00" in "output/2013/04/10/entry2/index.html"

    # TODO: this behavior has changed, pre-resource engine it would have output both under 2013/04/09
    Scenario: Generate proper dates with explicitly set timezone (different than posts' time)
      Given I have a _layouts directory
      And I have a page layout that contains "Page Layout: {{ collections.posts.resources.size }}"
      And I have a post layout that contains "Post Layout: {{ content }} built at {{ page.date | date_to_xmlschema }}"
      And I have an "index.html" page with layout "page" that contains "site index page"
      And I have a configuration file with:
        | key         | value                |
        | timezone    | Pacific/Honolulu     |
      And I have a _posts directory
      And I have the following posts:
        | title     | date                   | layout  | content             |
        | entry1    | 2013-04-09 23:22 +0400 | post    | content for entry1. |
        | entry2    | 2013-04-10 03:14 +0400 | post    | content for entry2. |
      When I run bridgetown build
      Then I should get a zero exit status
    And the output directory should exist
      And I should see "Page Layout: 2" in "output/index.html"
      And the "output/2013/04/09/entry1/index.html" file should exist
      And the "output/2013/04/10/entry2/index.html" file should exist
      And I should see "Post Layout: <p>content for entry1.</p>\n built at 2013-04-09T09:22:00-10:00" in "output/2013/04/09/entry1/index.html"
      And I should see "Post Layout: <p>content for entry2.</p>\n built at 2013-04-09T13:14:00-10:00" in "output/2013/04/10/entry2/index.html"

  Scenario: arbitrary file reads via layouts
    Given I have an "index.html" page with layout "page" that contains "FOO"
    And I have a "bridgetown.config.yml" file that contains "layouts: '../../../../../../../../../../../../../../usr/include'"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "FOO" in "output/index.html"
    And I should not see " " in "output/index.html"

  Scenario: Allow collapsed Zeitwerk dirs with specific dir name
    Given I have a "plugins/nested" directory
    And I have a "plugins/nested/top_level.rb" file with content:
    """
    module TopLevel
      Bridgetown::Hooks.register :site, :after_reset do |site|
        pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
        pg.content = "Zeitwerk specific dir"

        site.generated_pages << pg
      end
    end
    """
    And I have a "bridgetown.config.yml" file with content:
    """
    autoloader_collapsed_paths:
    - plugins/nested
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Zeitwerk specific dir" in "output/foo/index.html"

  Scenario: Allow collapsed Zeitwerk dirs using globs
    Given I have a "plugins/nested" directory
    And I have a "plugins/nested/subnested" directory
    And I have a "plugins/nested/top_level.rb" file with content:
    """
    module TopLevel
      Bridgetown::Hooks.register :site, :after_reset do |site|
        pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
        pg.content = "Zeitwerk glob dir"

        site.generated_pages << pg
      end
    end
    """
    And I have a "plugins/nested/subnested/lower_level.rb" file with content:
    """
    module Subnested::LowerLevel
      Bridgetown::Hooks.register :site, :after_reset do |site|
        pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "bar.html")
        pg.content = "Zeitwerk glob subnested dir"

        site.generated_pages << pg
      end
    end
    """
    And I have a "bridgetown.config.yml" file with content:
    """
    autoloader_collapsed_paths:
    - plugins/*
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Zeitwerk glob dir" in "output/foo/index.html"
    And I should see "Zeitwerk glob subnested dir" in "output/bar/index.html"

