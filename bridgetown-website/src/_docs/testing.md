---
order: 4.7
next_page_order: 5
title: Automated Testing
top_section: Setup
category: testing
---

Running an automated test suite after your Bridgetown site has been built is a great way to ensure important content is available and formatted as you expect, and that some recent change hasn't broken anything critical within your build process.

Bridgetown doesn't come with an opinionated testing setup, so you're welcome to choose from a variety of approaches—and perhaps even use several at once!

{% toc %}

## Use Ruby and Minitest to Test HTML Directly

You can run a [bundled configuration](/docs/bundled-configurations) on your site to add a [`post_write` hook plugin](/docs/plugins/hooks) which kicks off a Minitest-based test suite. The plugin will automatically detect if the [Bridgetown environment](/docs/configuration/environments) isn't `development` (i.e. it's `test` or `production`) and if the optional set of test gems (Minitest, Nokogiri, etc.) are available. If so, the tests will run after the site has been built.

One of the benefits of this testing approach is it's _very_ fast, due to the fact that all the static HTML has been built and is in memory when the test suite runs.

To install, run the following command:

```sh
bundle exec bridgetown configure minitesting
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


There are a couple of ways to add Cypress to your testing setup. The first
option is to use an automation like [bridgetown-automation-cypress](https://github.com/ParamagicDev/bridgetown-automation-cypress). The other option is to add it manually.

To install via an automation, run:

```sh
bin/bridgetown apply https://github.com/ParamagicDev/bridgetown-automation-cypress
```

then skip down to the **Adding Tests** section.

### Manual Installation

To add Cypress manually, first you must install
[Cypress](https://www.cypress.io/) as well as a package called [start-server-and-test](https://github.com/bahmutov/start-server-and-test).

To do so, run the following command in the terminal:

```bash
yarn add -D cypress start-server-and-test
```

### Setting a baseUrl

An important part of cypress is to set a `baseUrl` inside of your
`cypress.json` file.

Setting a baseUrl prepends the value anytime you type `cy.visit()`. So if you were to type `cy.visit("/")` it would be equivalent to `cy.visit("http://localhost:4000/")`.

We will set our `baseUrl` to 4001 because this is technically where a
Bridgetown app is running. A tool called `browser-sync` proxies port
`4001` to port `4000` for us.

```json
{
  "__filename": "cypress.json",
  "baseUrl": "http://localhost:4000"
}
```

### Adding Scripts

Let's look at the base commands of Cypress and how we can access them by adding scripts to
our `package.json` file.

The first command we will look at is `cypress open`.

`cypress open` opens up a GUI to allow you to select which test(s) you
would like to run. To run it in your project, type the following
into your terminal:

```bash
yarn start-server-and-test 'bin/bridgetown start' http-get://localhost:4001 'yarn cy:open'
```

The other command you can run is `cypress run`.

`cypress run` runs a headless browser which outputs testing progress to the terminal. It is
meant for things like CI environments that cannot open up a headed browser. To
run this command simply type the following in your project:

```bash
yarn start-server-and-test 'bin/bridgetown start' http-get://localhost:4001 'yarn cy:open'
```

#### package.json scripts

To save time, let's add some useful scripts to our `package.json` file.

```json
{
  "__filename": "package.json",
  "scripts": {
    "cy:open": "cypress open",
    "cy:test": "start-server-and-test 'bin/bridgetown start' http-get://localhost:4001 'yarn cy:open'",
    "cy:run": "cypress run",
    "cy:test:ci": "start-server-and-test 'bin/bridgetown start' http-get://localhost:4001 'yarn cy:run'"
  }
}
```

Now to test our site we simply have to do:

```bash
yarn cy:open
```

And our site will now be tested with Cypress.

So go ahead and run that
command and this will prepopulate the `cypress/` directory where you
will add future tests.

### Adding Tests

Now that we've finished setting up lets look at the `cypress/`
directory. Lets start by removing the `cypress/integration/examples/` directory.

```bash
rm -rf cypress/integration/examples
```

So now let's create our first test. Create a file called `navbar.spec.js`
inside of the `cypress/integrations` directory.

Inside of the file let's add some assertions. (This is assuming you are
using a new Bridgetown project.)

```javascript
// cypress/integrations/navbar.spec.js

describe("Testing that links exist in the navbar", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("navbar links appear on all pages", () => {
    const baseUrl = Cypress.config("baseUrl");

    cy.get('[href="/"]').click();
    cy.url().should("eq", baseUrl + "/");

    cy.get('[href="/posts"]').click();
    cy.url().should("eq", baseUrl + "/posts/");

    cy.get('[href="/about"]').click();
    cy.url().should("eq", baseUrl + "/about/");
  });
});
```

Now when we run all tests, they all should pass. And now we have a
starting point for creating more Cypress tests.

[Reference Repository for Cypress
Testing](https://github.com/ParamagicDev/bridgetown-example-cypress)
