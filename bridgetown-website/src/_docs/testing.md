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

### Installation

There are a couple of ways to add Cypress to your testing setup. The first
option is to use an automation like [bridgetown-automation-cypress](https://github.com/ParamagicDev/bridgetown-automation-cypress). The other option is to add it manually.

To add Cypress manually, first you must install
[Cypress](https://www.cypress.io/) as well as a package called [start-server-and-test](https://github.com/bahmutov/start-server-and-test).

To do so, run the following command in the terminal:

```bash
yarn add -D cypress start-server-and-test
```

### Setting a baseUrl

An important part of cypress is to use a set a `baseUrl` inside of your
`cypress.json` file.

Setting a baseUrl prepends the value anytime you type `cy.visit()`

We will set our `baseUrl` to 4001 because this is technically where a
Bridgetown app is running. A tool called `browser-sync` proxies port
`4001` to port `4000` for us.

```json
{
  "__filename": "package.json",
  "baseUrl": "http://localhost:4000"
}
```

### Adding Scripts

Bridgetown uses [Webpack](https://webpack.js.org/) under the hood so it
requires a little bit of extra work to run Cypress. Lets look at the
base commands of Cypress and how we can extend them to add scripts to
our `package.json` file.

The first command we will look at is `cypress open`.

`cypress open` opens up a browser and provides an automated browser
testing that you can see. To run it in your project, type the following
into your terminal:

```bash
yarn start-server-and-test 'yarn start' http-get://localhost:4001 'yarn cy:open'
```

The other command you can run is `cypress run`.

`cypress run` runs an automated browser test in the terminal. It is
meant for things like CI environments that cannot open up a browser. To
run this command simply type the following in your project:

```bash
yarn start-server-and-test 'yarn start' http-get://localhost:4001 'yarn cy:open'
```

#### package.json scripts

To save time, lets add some useful scripts to our `package.json` file.

```json
{
  "scripts": {
    "cy:open": "cypress open",
    "cy:test": "start-server-and-test 'yarn start' http-get://localhost:4001 'yarn cy:open'",
    "cy:run": "cypress run",
    "cy:test:ci": "start-server-and-test 'yarn start' http-get://localhost:4001 'yarn cy:run'"
  }
}
```

Now to test our site we simply have to do:

```bash
yarn cy:test
```

And our site will now be tested with Cypress.

So go ahead and run that
command and you will prepopulate the `cypress/` directory where you
will add future tests.

### Adding Tests

Now that we've finished setting up lets look at the `cypress/`
directory. Lets start by removing the `cypress/integration/examples/` directory.

```bash
rm -rf cypress/integration/examples
```

So now lets create our first test. Create a file called `app_test.js`
inside of the `cypress/integrations` directory.

Inside of the file lets add some assertions. (This is assuming you are
using a new Bridgetown project.)

```javascript
// cypress/integrations/app_test.js

describe("Testing that links exist in the navbar", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  context("navbar appears on all pages with all links", () => {
    cy.get('[href="/"]').click();
    cy.get('[href="/posts"]').click();
    cy.get('[href="/about"]').click();
  });
});
```

Now when we run all specs, they all should pass. And now we have a
starting point for creating more Cypress tests.

[Reference Repository for Cypress
Testing](https://github.com/ParamagicDev/bridgetown-example-cypress)
