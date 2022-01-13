---
order: 190
title: Automated Testing
top_section: Publishing Your Site
category: testing
---

Running an automated test suite after your Bridgetown site has been built is a great way to ensure important content is available and formatted as you expect, and that some recent change hasn't broken anything critical within your build process.

Bridgetown doesn't come with an opinionated testing setup, so you're welcome to choose from a variety of approaches—and perhaps even use several at once!

{{ toc }}

## Use Ruby and Minitest to Test HTML Directly

You can run a [bundled configuration](/docs/bundled-configurations#automated-test-suite-using-minitest) on your site to add a [`post_write` hook plugin](/docs/plugins/hooks) which kicks off a Minitest-based test suite. The plugin will automatically detect if the [Bridgetown environment](/docs/configuration/environments) isn't `development` (i.e. it's `test` or `production`) and if the optional set of test gems (Minitest, Nokogiri, etc.) are available. If so, the tests will run after the site has been built.

One of the benefits of this testing approach is it's _very_ fast, due to the fact that all the static HTML has been built and is in memory when the test suite runs.

To install, run the following command:

```sh
bin/bridgetown configure minitesting
```

This will set up the plugin, test gems, and an example test suite in the `test` folder.

The tests you write will be simple DOM selection assertions that operate on the output HTML that's in memory after the site has been rendered, so they run extremely fast. You use the native Ruby APIs provided by Bridgetown to find pages to test, and use assertions you may be familiar with from the Ruby on Rails framework (such as `assert_select` and `assert_dom_equal`). Here's an example of such a test:

```ruby
require_relative "./helper"

class TestBlog < Minitest::Test
  context "blog page" do
    setup do
      page = site.collections.pages.resources.find { |page| page.relative_url == "/blog/index.html" }
      document_root page
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

You can add additional contexts and "should" blocks to a test file, and you can create as many test files as you want to handle various parts of the site.

As part of the automation setup mentioned above, you should now have new scripts in `package.json`: `test` and `deploy:test`.

* `test`: Builds the site using the **test** environment (requires you first to run `bundle install --with test` on your machine).
* `deploy:test`: Installs the test gems and then runs `deploy`. Note this does not specify a particular environment—it's up to you to set that to **production** or otherwise as part of your deployment context.

## Headless Browser Testing with Cypress

You can install Cypress using a [bundled configuration](/docs/bundled-configurations). Just run:

```sh
bin/bridgetown configure cypress
```

The above command will add a `cypress/` directory to your project. Within this directory you can see the `integration/navbar.spec.js` file as an example of how to write your tests.

The test suite can be run using:

```sh
bin/bridgetown cy:test:ci
```

A number of other useful commands are also installed along with Cypress:

```sh
# Opens the Cypress test runner.
bin/bridgetown cy:open

# Starts the Bridgetown server and opens the Cypress test runner.
bin/bridgetown cy:test

# Runs the Cypress tests headlessly in the Electron browser.
bin/bridgetown cy:run
```
