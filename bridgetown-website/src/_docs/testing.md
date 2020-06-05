---
order: 4.7
next_page_order: 5
title: Automated Testing
top_section: Setup
category: testing
---

Running an automated test suite after your Bridgetown site has been built is a great way to ensure important content is available and formatted as you expect, and that some recent change hasn't broken anything critical within your build process.

Bridgetown doesn't come with an opinionated testing setup, so you're welcome to choose from a variety of approaches—and perhaps even use several at once!

## Use Ruby and Minitest to Test HTML Directly

New in Bridgetown 0.15, you can apply an automation to your site to add a [`post_write` hook plugin](/docs/plugins/hooks) that kicks off a Minitest-based test suite. The plugin will automatically detect if the [Bridgetown environment](/docs/configuration/environments) isn't `development` (aka it's `test` or `production`) and if the optional set of test gems (Minitest, Nokogiri, etc.) are available. If so, the tests will run after the site has been built.

The tests you write will be simple DOM selection assertions that operate on the output HTML that's in memory after the site has been rendered, so they run extremely fast. You use the native Ruby APIs provided by Bridgetown to find pages to test, and use assertions you may be familiar with from the Ruby on Rails framework (such as `assert_select` and `assert_dom_equal`). Here's an example of such a test:

```ruby
require_relative "./helper"

class TestBlog < Minitest::Test
  context "blog page" do
    setup do
      page = site.pages.find { |doc| doc.url == "/blog/index.html" }
      document_root nokogiri(page)
    end

    should "show authors" do
      assert_select ".box .author img" do |imgs|
        assert_dom_equal imgs.last.to_html,
                         '<img src="/images/khristi-jamil-avatar.jpg" alt="Khristi Jamil" class="avatar">'
      end
    end
  end
end
```

TBC…

## Headless Browser Testing with Cypress

TBC…