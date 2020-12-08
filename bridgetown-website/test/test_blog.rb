# frozen_string_literal: true

require_relative "./helper"

class TestBlog < Minitest::Test
  context "blog page" do
    setup do
      page = site.pages.find { |doc| doc.url == "/blog/index.html" }
      document_root page
    end

    should "show authors" do
      assert_select ".box .author img" do |imgs|
        assert_dom_equal imgs.last.to_html,
                         '<img src="/images/jared-white-avatar.jpg" alt="Jared White" class="avatar u-photo" loading="lazy">'
      end
    end

    should "have correct microformat markup" do
      assert_select ".h-entry h2.p-name"
      assert_select ".h-entry article-content.p-summary"
      assert_select ".h-entry article-author.p-author"
    end
  end

  context "blog page" do
    setup do
      page = site.collections[:docs].docs.find { |doc| doc.url == "/docs/plugins" }
      document_root nokogiri(page)
    end

    should "have a formatted JSON code example" do
      assert_select "div.language-json pre.highlight", <<~JSON
        "dependencies": {
          "random-js-package": "2.4.6",
          "my-plugin": "../my-plugin"
        }
      JSON
    end
  end

  context "blog post" do
    setup do
      page = site.posts.docs.find { |doc| doc.url == "/release/whats-new-in-0.14-hazelwood/" }
      document_root nokogiri(page)
    end

    should "display a Builder code example" do
      assert_select ".box > article > h1" do |h1|
        assert_dom_equal h1.to_html, '<h1 class="mt-3 mb-10 title is-1 is-size-2-mobile has-text-centered has-text-brown p-name">A Bridge to the Future: What’s New in Bridgetown 0.14 “Hazelwood”</h1>'
      end

      code_example = <<~RUBY
        # plugins/builders/welcome_to_hazelwood.rb
        class WelcomeToHazelwood < SiteBuilder
          def build
            liquid_tag "welcome" do |attributes|
              "Welcome to Hazelwood, \#{attributes}!"
            end
            liquid_filter "party_time", :party_time

            add_new_posts
          end

          def party_time(input)
            "\#{input} 🥳"
          end

          def add_new_posts
            get "https://domain.com/posts.json" do |data|
              data.each do |post|
                doc "\#{post[:slug]}.md" do
                  front_matter post
                  categories post[:taxonomy][:category].map { |category| category[:slug] }
                  date Bridgetown::Utils.parse_date(post[:date])
                  content post[:body]
                end
              end
            end
          end
        end
      RUBY

      assert_select ".content > div.language-ruby:nth-of-type(1) pre.highlight", code_example
    end
  end
end
