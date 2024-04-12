# frozen_string_literal: true

require "features/feature_helper"

# As a plugin author, I want to be able to run code during various stages of the build process
class TestFastRefresh < BridgetownFeatureTest
  context "fast refresh" do
    setup do
      create_directory "config"
      create_configuration fast_refresh: true
    end

    should "rebuild page via signals without a full site build" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          iterations = 1
          hook :site, :pre_render do |site|
            site.signals.iterations = iterations
          end
          # This will refresh a couple of times:
          hook :site, :post_write do |site|
            next unless iterations < 3

            iterations +=1
            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.signals.iterations = iterations
              site.fast_refresh
            end.value
          end
        end
      RUBY

      create_page "index.erb", "Iterations! <%= site.signals.iterations %>", title: "test"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "Iterations! 3", "output/index.html"
    end

    should "rebuild page because partial changed" do
      create_directory "_partials"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          iterations = 1

          # This will refresh:
          hook :site, :post_write do |site|
            next unless iterations < 2

            iterations +=1
            partial_path = site.in_source_dir("_partials", "_test.erb")
            File.write(partial_path, "Right value")
            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([partial_path])
            end.value
          end
        end
      RUBY

      create_file "_partials/_test.erb", "Wrong value"
      create_page "index.erb", "Value: <%= render 'test' %>", title: "test"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "Value: Right value", "output/index.html"
    end

    should "rebuild page because component changed" do
      create_directory "_components"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            component_path = site.in_source_dir("_components", "test_component.rb")
            component_text = File.read(component_path)
            File.write(component_path, component_text.sub("Wrong", "Right"))
            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([component_path])
            end.value
          end
        end
      RUBY

      create_file "_components/test_component.rb", <<~RUBY
        class TestComponent < Bridgetown::Component
          def correctness
            "Wrong"
          end
        end
      RUBY
      create_file "_components/test_component.erb", "<%= correctness %> value"
      create_page "index.erb", "Component: <%= render TestComponent.new %>", title: "test"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "Component: Right value", "output/index.html"
    end

    should "rebuild page because component template changed" do
      create_directory "_components"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            component_path = site.in_source_dir("_components", "test_component.erb")
            component_text = File.read(component_path)
            File.write(component_path, component_text.sub("Wrong", "Right"))
            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([component_path])
            end.value
          end
        end
      RUBY

      create_file "_components/test_component.rb", <<~RUBY
        class TestComponent < Bridgetown::Component
          attr_reader :input
          def initialize(input:)
            @input = input
          end
        end
      RUBY
      create_file "_components/test_component.erb", "Wrong <%= input %>"
      create_page "index.erb", "Component: <%= render TestComponent.new(input: 'value') %>", title: "test"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "Component: Right value", "output/index.html"
    end

    should "rebuild page because layout changed" do
      create_directory "_layouts"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            layout_path = site.in_source_dir("_layouts", "page.liquid")
            layout_text = File.read(layout_path)
            File.write(layout_path, layout_text.sub("Wrong", "Right"))

            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([layout_path])
            end.value
          end
        end
      RUBY

      create_file "_layouts/page.liquid", <<~LIQUID
        {{content }}: Wrong value
      LIQUID
      create_page "index.erb", "Layout", title: "test", layout: "page"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "Layout\n: Right value", "output/index.html"
    end

    should "rebuild page because page changed" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            page_path = site.in_source_dir("index.md")
            page_text = File.read(page_path)
            File.write(page_path, page_text.sub("Wrong", "Right"))

            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([page_path], reload_if_needed: true)
            end.value
          end
        end
      RUBY

      create_page "index.md", "Value: _Wrong_", title: "test"

      _, output = run_bridgetown "build"

      assert_includes output, "1 resource fast refreshed"
      assert_file_contains "<p>Value: <em>Right</em></p>", "output/index.html"
    end

    should "not fast refresh because page taxonomy changed" do
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          template_engine "erb"
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            page_path = site.in_source_dir("index.md")
            page_text = File.read(page_path)
            File.write(page_path, page_text.sub("tag1", "tag2"))

            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([page_path], reload_if_needed: true)
            end.value
          end
        end
      RUBY

      create_page "index.md", "Content <%= data.tags %>", title: "test", tags: "tag1"

      _, output = run_bridgetown "build"

      refute_includes output, "1 resource fast refreshed"
      assert_file_contains "<p>Content [\"tag2\"]</p>", "output/index.html"
    end
  end

  context "fast refresh and prototype pages" do
    setup do
      create_directory "config"
      create_directory "_posts"
      create_directory "authors"

      create_page "_posts/wargames.md", "The only winning move is not to play.", title: "Wargames", author: ["john doe", "jenny"], date: "2009-03-27"
      create_page "_posts/wargames2.md", "The only winning move is not to play2.", title: "Wargames2", author: "jackson", date: "2009-04-27"
      create_page "_posts/wargames3.md", "The only winning move is not to play3.", title: "Wargames3", author: "melinda, jackson", date: "2009-05-27"
      create_page "_posts/wargames4.md", "The only winning move is not to play4.", title: "Wargames4", author: "fred ; jackson", date: "2009-06-27"
    end

    should "re-generate author pages on post change" do
      example = { num: 1, exist: 3, posts: 1, not_exist: 4, title: "Wargames2" }
      create_configuration fast_refresh: true, pagination: { enabled: true, per_page: example[:num] }

      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            page_path = site.in_source_dir("_posts/wargames2.md")
            page_text = File.read(page_path)
            File.write(page_path, page_text.sub("Wargames2", "WargamesNext"))
            puts page_path, File.read(page_path)

            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([page_path])
            end.value
          end
        end
      RUBY

      create_page "authors/author.serb", "\#{{ page.data.author }} {{ paginator.resources.size }} {{ paginator.resources[0].data.title }}", prototype: { collection: "posts", term: "author" }

      _, output = run_bridgetown "build"
      assert_includes output, "1 resource fast refreshed"
      assert_includes output, "1 generated page fast refreshed"

      assert_file_contains "#jackson #{example[:posts]} WargamesNext", "output/authors/jackson/page/#{example[:exist]}/index.html"
    end

    should "re-generate author pages on protoype change" do
      example = { num: 1, exist: 3, posts: 1, not_exist: 4, title: "Wargames2" }
      create_configuration fast_refresh: true, pagination: { enabled: true, per_page: example[:num] }

      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          hook_ran = false

          # This will refresh:
          hook :site, :post_write do |site|
            next if hook_ran

            hook_ran = true
            page_path = site.in_source_dir("authors/author.serb")
            page_text = File.read(page_path)
            File.write(page_path, page_text.sub("One", "Two"))
            puts page_path, File.read(page_path)

            Concurrent::ScheduledTask.execute(0.1) do
              Bridgetown::Current.site = site
              site.fast_refresh([page_path])
            end.value
          end
        end
      RUBY

      create_page "authors/author.serb", "\#{{ page.data.author }} One {{ paginator.resources.size }} {{ paginator.resources[0].data.title }}", prototype: { collection: "posts", term: "author" }

      _, output = run_bridgetown "build"
      assert_includes output, "1 resource fast refreshed"
      assert_includes output, "7 generated pages fast refreshed"

      assert_file_contains "#jackson Two #{example[:posts]} Wargames2", "output/authors/jackson/page/#{example[:exist]}/index.html"
    end
  end
end
