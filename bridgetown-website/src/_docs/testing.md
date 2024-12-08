---
order: 190
title: Automated Testing
top_section: Publishing Your Site
category: testing
---

Running an automated test suite after your Bridgetown site has been built is a great way to ensure important content is available and formatted as you expect, and that some recent change hasn't broken anything critical within your build process.

{{ toc }}

## Use Ruby and Minitest to Test HTML Directly

Bridgetown provides a [bundled configuration](/docs/bundled-configurations#automated-test-suite-using-minitest) to add gems for [Minitest](https://docs.seattlerb.org/minitest/) and [Rack::Test](https://github.com/rack/rack-test) and set up the test environment in the `test` folder.

To install, run the following command:

```sh
bin/bridgetown configure minitesting
```

You can write tests to verify the output of both static and dynamic routes. Right when the test suite first runs, the Bridgetown site will be built (via the `test` [environment](/docs/configuration/environments)) so that static pages are available. Then, the [Roda server application](/docs/routes) will boot up in memory and you can make direct requests much as if you were using a full HTTP server.

The `html` and `json` helpers let you parse responses, either as a [Nokolexbor](https://github.com/serpapi/nokolexbor) document in the case of an HTML response, or `JSON.parse` in the case of a JSON response.

Here's an example of such a test:

```ruby
require "minitest_helper"

class TestBlog < Bridgetown::Test
  def test_authors
    html get "/blog"

    assert_equal '<img src="/images/khristi-jamil-avatar.jpg" alt="Khristi Jamil" class="avatar">',
                 document.query_selector_all(".box .author img").last.outer_html
  end
end
```

There are `get`, `post`, and `delete` methods available for testing various server routes. For more information, read the [Rack::Test](https://github.com/rack/rack-test) documentation. You can also access the Bridgetown site object loaded in memory via the `site` helper. For example, `site.metadata.title` would return your site's title as defined in `_data/site_metadata.yml`.

You can add additional tests via `test_*` methods, and you can create as many test files as you want to handle various parts of the site. Be advised that these tests are run via the `server` initialization context, so it's possible something may not have run as you would expect under a `static` initialization context. But since the static site is already built prior to your tests being executed, it's probably best for you to test static use cases via the output HTML.

## Headless Browser Testing with Cypress

You can install Cypress using a [bundled configuration](/docs/bundled-configurations):

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
