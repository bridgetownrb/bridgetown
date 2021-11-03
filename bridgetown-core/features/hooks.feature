Feature: Hooks
  As a plugin author
  I want to be able to run code during various stages of the build process

  Scenario: Run some code after site reset
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :site, :after_reset do |site|
        pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
        pg.content = "mytinypage"

        site.generated_pages << pg
      end
    end
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "mytinypage" in "output/foo/index.html"

  Scenario: Modify the site contents after reading
    Given I have a plugins directory
    And I have a "page1.html" page that contains "page1"
    And I have a "page2.html" page that contains "page2"
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :site, :post_read do |site|
        site.collections.pages.resources.delete_if { |p| p.relative_path.basename.to_s == 'page1.html' }
      end
    end
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And the "output/page1/index.html" file should not exist
    And I should see "page2" in "output/page2/index.html"

  Scenario: Work with the site files after they've been written to disk
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :site, :post_write do |site|
        firstpage = site.collections.pages.resources.first
        content = File.read firstpage.destination.output_path
        File.write(File.join(site.dest, 'firstpage.html'), content)
      end
    end
    """
    And I have a "page1.html" page that contains "page1"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "page1" in "output/firstpage.html"

  Scenario: Modify page contents before writing to disk
    Given I have a plugins directory
    And I have a "index.html" page that contains "WRAP ME"
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :pages, :post_render do |page|
        page.output = "{{{{{ #{page.output.chomp} }}}}}"
      end
    end
    """
    When I run bridgetown build
    Then I should see "{{{{{ WRAP ME }}}}}" in "output/index.html"

  Scenario: Work with a page after writing it to disk
    Given I have a plugins directory
    And I have a "index.html" page that contains "HELLO FROM A PAGE"
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :pages, :post_write do |page|
        require 'fileutils'
        filename = page.destination.output_path
        FileUtils.mv(filename, "#{filename}.moved")
      end
    end
    """
    When I run bridgetown build
    Then I should see "HELLO FROM A PAGE" in "output/index.html.moved"

  Scenario: Alter a post right after it is initialized
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :posts, :post_init do |post|
        post.data['harold'] = "content for entry1.".tr!('abcdefghijklmnopqrstuvwxyz',
              'nopqrstuvwxyzabcdefghijklm')
      end
    end
    """
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content               |
      | entry1 | 2015-03-14 | nil    | {{ page.harold }} |
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "pbagrag sbe ragel1." in "output/2015/03/14/entry1/index.html"

  Scenario: Alter frontmatter data for certain posts
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    # Add myvar = 'old' to posts before 2015-03-15, and myvar = 'new' for
    # others
    module Ext
      Bridgetown::Hooks.register :posts, :pre_render do |post|
        if post.date < Time.new(2015, 3, 15)
          post.data.myvar = 'old'
        else
          post.data.myvar = 'new'
        end
      end
    end
    """
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content               |
      | entry1 | 2015-03-14 | nil    | {{ page.myvar }} post |
      | entry2 | 2015-03-15 | nil    | {{ page.myvar }} post |
    When I run bridgetown build
    Then I should see "old post" in "output/2015/03/14/entry1/index.html"
    And I should see "new post" in "output/2015/03/15/entry2/index.html"

  Scenario: Modify post contents before writing to disk
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    # Replace content after rendering
    module Ext
      Bridgetown::Hooks.register :posts, :post_render do |post|
        post.output.gsub! /42/, 'the answer to life, the universe and everything'
      end
    end
    """
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content             |
      | entry1 | 2015-03-14 | nil    | {{ 6 \| times: 7 }} |
      | entry2 | 2015-03-15 | nil    | {{ 6 \| times: 8 }} |
    When I run bridgetown build
    Then I should see "the answer to life, the universe and everything" in "output/2015/03/14/entry1/index.html"
    And I should see "48" in "output/2015/03/15/entry2/index.html"

  Scenario: Work with a post after writing it to disk
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    # Log all post filesystem writes
    module Ext
      Bridgetown::Hooks.register :posts, :post_write do |post|
        filename = post.destination.output_path
        open('output/post-build.log', 'a') do |f|
          f.puts "Wrote #{filename} at #{Time.now}"
        end
      end
    end
    """
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content   |
      | entry1 | 2015-03-14 | nil    | entry one |
      | entry2 | 2015-03-15 | nil    | entry two |
    When I run bridgetown build
    Then I should see "output/2015/03/14/entry1/index.html at" in "output/post-build.log"
    Then I should see "output/2015/03/15/entry2/index.html at" in "output/post-build.log"

  Scenario: Register a hook on multiple owners at the same time
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register [:pages, :posts], :post_render do |owner|
        owner.output = "{{{{{ #{owner.output.chomp} }}}}}"
      end
    end
    """
    And I have a "index.html" page that contains "WRAP ME"
    And I have a _posts directory
    And I have the following posts:
      | title  | date       | layout | content   |
      | entry1 | 2015-03-14 | nil    | entry one |
    When I run bridgetown build
    Then I should see "{{{{{ WRAP ME }}}}}" in "output/index.html"
    And I should see "{{{{{ <p>entry one</p> }}}}}" in "output/2015/03/14/entry1/index.html"

  Scenario: Allow hooks to have a named priority
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :pages, :post_render, priority: :normal do |owner|
        # first normal runs second
        owner.output = "1 #{owner.output.chomp}"
      end
      Bridgetown::Hooks.register :pages, :post_render, priority: :high do |owner|
        # high runs first
        owner.output = "2 #{owner.output.chomp}"
      end
      Bridgetown::Hooks.register :pages, :post_render do |owner|
        # second normal runs third (normal is default)
        owner.output = "3 #{owner.output.chomp}"
      end
      Bridgetown::Hooks.register :pages, :post_render, priority: :low do |owner|
        # low runs last 
        owner.output = "4 #{owner.output.chomp}"
      end
    end
    """
    And I have a "index.html" page that contains "WRAP ME"
    When I run bridgetown build
    Then I should see "4 3 1 2 WRAP ME" in "output/index.html"

  Scenario: Alter a document right after it is initialized
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :resources, :pre_render do |doc, payload|
        doc.data['text'] = doc.data['text'] << ' are belong to us' if doc.data['text']
      end
    end
    """
    And I have a "bridgetown.config.yml" file that contains "collections: [ memes ]"
    And I have a _memes directory
    And I have a "_memes/doc1.md" file with content:
    """
    ---
    text: all your base
    ---
    """
    And I have an "index.md" file with content:
    """
    ---
    ---
    {{ collections.memes.resources.first.text }}
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "all your base are belong to us" in "output/index.html"

  Scenario: Update a document after rendering it, but before writing it to disk
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :resources, :post_render do |doc|
        doc.output.gsub! /<p>/, '<p class="meme">'
      end
    end
    """
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      memes:
        output: true
    """
    And I have a _memes directory
    And I have a "_memes/doc1.md" file with content:
    """
    ---
    text: all your base are belong to us
    ---
    {{ page.text }}
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<p class=\"meme\">all your base are belong to us" in "output/memes/doc1/index.html"

  Scenario: Perform an action after every document is written
    Given I have a plugins directory
    And I have a "plugins/ext.rb" file with content:
    """
    module Ext
      Bridgetown::Hooks.register :resources, :post_write do |doc|
        open('output/document-build.log', 'a') do |f|
          f.puts "Wrote document #{doc.collection.resources.index doc} at #{Time.now}"
        end
      end
    end
    """
    And I have a "bridgetown.config.yml" file with content:
    """
    collections:
      memes:
        output: true
    """
    And I have a _memes directory
    And I have a "_memes/doc1.md" file with content:
    """
    ---
    text: all your base are belong to us
    ---
    {{ page.text }}
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Wrote document 0" in "output/document-build.log"
