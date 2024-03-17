# frozen_string_literal: true

require "features/feature_helper"

# As a plugin author, I want to be able to run code during various stages of the build process
class TestHooks < BridgetownFeatureTest
  context "hooks" do
    setup do
      create_directory "plugins"
      create_directory "config"
    end

    should "run after site reset" do
      create_file "plugins/ext.rb", <<~RUBY
        module Ext
          Bridgetown::Hooks.register :site, :after_reset do |site|
            pg = Bridgetown::GeneratedPage.new(site, site.source, "/", "foo.html")
            pg.content = "mytinypage"

            site.generated_pages << pg
          end
        end
      RUBY

      run_bridgetown "build"

      assert_file_contains "mytinypage", "output/foo/index.html"
    end

    should "modify the site after being read" do
      create_page "page1.html", "page1", title: "Page 1"
      create_page "page2.html", "page2", title: "Page 2"

      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook :site, :post_read do |site|
            site.collections.pages.resources.delete_if { |p| p.relative_path.basename.to_s == 'page1.html' }
          end
        end
      RUBY

      run_bridgetown "build"

      refute_exist "output/page1/index.html"
      assert_file_contains "page2", "output/page2/index.html"
    end

    should "work with site files after being written to disk" do
      create_page "page1.html", "page1", title: "Page 1"

      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook :site, :post_write do |site|
            firstpage = site.collections.pages.resources.first
            content = File.read firstpage.destination.output_path
            File.write(File.join(site.dest, 'firstpage.html'), content)
          end
        end
      RUBY

      run_bridgetown "build"

      assert_file_contains "page1", "output/firstpage.html"
    end

    should "modify page contents before writing to disk" do
      create_page "index.html", "WRAP ME", title: "Simple Test"

      create_file "plugins/ext.rb", <<~RUBY
        module Ext
          Bridgetown::Hooks.register :pages, :post_render do |page|
            page.output = "{{{{{ \#{page.output.chomp} }}}}}"
          end
        end
      RUBY

      run_bridgetown "build"

      assert_file_contains "{{{{{ WRAP ME }}}}}", "output/index.html"
    end

    should "work with a page after writing it to disk" do
      create_page "index.html", "HELLO FROM A PAGE", title: "Simple Test"

      create_file "plugins/ext.rb", <<~RUBY
        module Ext
          Bridgetown::Hooks.register :pages, :post_write do |page|
            require 'fileutils'
            filename = page.destination.output_path
            FileUtils.mv(filename, "\#{filename}.moved")
          end
        end
      RUBY

      run_bridgetown "build"

      assert_file_contains "HELLO FROM A PAGE", "output/index.html.moved"
    end

    should "alter a post right after it is initialized" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook :posts, :post_init do |post|
            post.data['harold'] = "content for entry1.".tr!('abcdefghijklmnopqrstuvwxyz',
                  'nopqrstuvwxyzabcdefghijklm')
          end
        end
      RUBY

      create_directory "_posts"
      create_page "_posts/entry1.md", "{{ page.harold }}", title: "entry1", date: "2015-03-14"

      run_bridgetown "build"

      assert_file_contains "pbagrag sbe ragel1.", "output/2015/03/14/entry1/index.html"
    end

    should "alter frontmatter data for certain posts" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook :posts, :pre_render do |post|
            if post.date < Time.new(2015, 3, 15)
              post.data.myvar = 'old'
            else
              post.data.myvar = 'new'
            end
          end
        end
      RUBY

      create_directory "_posts"
      create_page "_posts/entry1.md", "{{ page.myvar }} post", title: "entry1", date: "2015-03-14"
      create_page "_posts/entry2.md", "{{ page.myvar }} post", title: "entry2", date: "2015-03-15"

      run_bridgetown "build"

      assert_file_contains "old post", "output/2015/03/14/entry1/index.html"
      assert_file_contains "new post", "output/2015/03/15/entry2/index.html"
    end

    should "modify post contents before writing to disk" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook :posts, :post_render do |post|
            post.output.gsub! /42/, 'the answer to life, the universe, and everything'
          end
        end
      RUBY

      create_directory "_posts"
      create_page "_posts/entry1.md", "{{ 6 | times: 7 }}", title: "entry1", date: "2015-03-14"
      create_page "_posts/entry2.md", "{{ 6 | times: 8 }}", title: "entry2", date: "2015-03-15"

      run_bridgetown "build"

      assert_file_contains "the answer to life, the universe, and everything", "output/2015/03/14/entry1/index.html"
      assert_file_contains "48", "output/2015/03/15/entry2/index.html"
    end

    should "work with a post after writing it to disk" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          # Log all post filesystem writes
          hook :posts, :post_write do |post|
            filename = post.destination.output_path
            open('output/post-build.log', 'a') do |f|
              f.puts "Wrote \#{filename} at \#{Time.now}"
            end
          end
        end
      RUBY

      create_directory "_posts"
      create_page "_posts/entry1.md", "entry1", title: "entry1", date: "2015-03-14"
      create_page "_posts/entry2.md", "entry2", title: "entry2", date: "2015-03-15"

      run_bridgetown "build"

      assert_file_contains "output/2015/03/14/entry1/index.html at #{Time.now.year}", "output/post-build.log"
      assert_file_contains "output/2015/03/15/entry2/index.html at #{Time.now.year}", "output/post-build.log"
    end

    should "register with multiple owners" do
      create_file "plugins/ext.rb", <<~RUBY
        module Ext
          Bridgetown::Hooks.register [:pages, :posts], :post_render do |owner|
            owner.output = "{{{{{ \#{owner.output.chomp} }}}}}"
          end
        end
      RUBY

      create_page "index.html", "WRAP ME", title: "Simple Test"
      create_directory "_posts"
      create_page "_posts/entry1.md", "entry one", title: "entry1", date: "2015-03-14"

      run_bridgetown "build"

      assert_file_contains "{{{{{ WRAP ME }}}}}", "output/index.html"
      assert_file_contains "{{{{{ <p>entry one</p> }}}}}", "output/2015/03/14/entry1/index.html"
    end

    should "allow different named priorities" do
      create_file "plugins/ext.rb", <<~RUBY
        module Ext
          Bridgetown::Hooks.register :pages, :post_render, priority: :normal do |owner|
            # first normal runs second
            owner.output = "1 \#{owner.output.chomp}"
          end
          Bridgetown::Hooks.register :pages, :post_render, priority: :high do |owner|
            # high runs first
            owner.output = "2 \#{owner.output.chomp}"
          end
          Bridgetown::Hooks.register :pages, :post_render do |owner|
            # second normal runs third (normal is default)
            owner.output = "3 \#{owner.output.chomp}"
          end
          Bridgetown::Hooks.register :pages, :post_render, priority: :low do |owner|
            # low runs last
            owner.output = "4 \#{owner.output.chomp}"
          end
        end
      RUBY

      create_page "index.html", "WRAP ME", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "4 3 1 2 WRAP ME", "output/index.html"
    end

    should "alter a document right after it is initialized" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          # Log all post filesystem writes
          hook :resources, :pre_render do |doc, payload|
            doc.data['text'] = doc.data['text'] << ' are belong to us' if doc.data['text']
          end
        end
      RUBY

      create_directory "_memes"
      create_page "_memes/doc1.md", "", text: "all your base"
      create_page "index.md", "{{ collections.memes.resources.first.text }}", title: "Simple test"

      create_configuration collections: ["memes"]

      run_bridgetown "build"

      assert_file_contains "all your base are belong to us", "output/index.html"
    end
  end
end
