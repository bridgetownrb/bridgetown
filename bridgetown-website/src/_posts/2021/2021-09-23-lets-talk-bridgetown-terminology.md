---
title: Let’s Talk Bridgetown Terminology
subtitle: As programmers, we tend to throw around a lot of arcane terms. Many of them may be unfamiliar at first glance. Time to break it all down!
author: jared
category: feature
---

As you read through our [documentation](/docs) or spend time in our [community chat](https://discord.gg/4E6hktQGz4), you'll discover we tend to throw around a lot of terms, many of which may be unfamiliar at first glance. It's easy to feel overwhelmed with all the different tools and options available. But never fear, it's time to break it all down!

### The Stack

Bridgetown is sometimes called a "static site generator" or a "Jamstack" web framework. What does any of that mean?

Perhaps it's simpler to think in terms of _progressive generation_, or the idea that the moment at which your HTML output + website assets is generated can vary depending on the tooling or the configuration you choose to use.

The main options available today are:

* **Static Site Generation (SSG)**, or build-time generation: you build your website output once and deploy it to a web server or CDN (Content Delivery Network). From then on, everything that website visitors see comes from those pre-built HTML/CSS/JS files. This is extremely performant as well as secure, because your website is nothing more than files in folders. No special per-request computation required. You can even pull data from APIs or headless CMSes at build time, and redeploy each time there's a major change.
* **Server-Side Rendering (SSR)**, or dynamic generation: you write backend code which then gets executed for each request/response cycle. This is necessary when you need to interact with a database or offer user-scoped functionality such as authentication and commerce. You can choose to expose certain SSR routes which will enhance the functionality of your primarily SSG'd website.
* **Client-Side Rendering (CSR)**, or reactive frontend: you write code which gets executed by the browser to provide on-page interactivity and handle UI events (mouse clicks, window resizing, etc.).
* **Partial or full hydration**: you use SSG/SSR techniques to render frontend components server-side, and then when the page is loaded by the browser, it will instantiate the frontend components using the SSG/SSR'd data and continue the CSR lifecycle from there.

There was a time when web frameworks which specialized primarily in SSG, SSR, or CSR were worlds apart from one another. But over the past couple of years, we've begun to see a convergence where a single "stack" (or at least a single code repository) can reliably address all these various rendering scenarios. Bridgetown is on track to deliver such a unified stack later this year with the release of v1.0, and we'll also provide examples of using Bridgetown for SSG alongside popular SSR frameworks such as Ruby on Rails.

### The Languages

![Ruby logo](/images/ruby.svg){:style="width:85px; float:right; margin: 0 0 10px 10px"} Bridgetown is mostly written in **Ruby**, a programming language first invented by [Yukihiro Matsumoto](https://en.wikipedia.org/wiki/Yukihiro_Matsumoto), or "Matz" as he is commonly known, back in 1995. Ruby has been called a language which optimizes for "programmer happiness", and that's certainly been our experience over the years. Ruby first saw widespread adoption in large part due to the rise of the **Ruby on Rails** web framework, but Ruby is far more applicable than just being the foundation of the Rails stack. We're constantly trying to find ways to make Bridgetown better not in spite of Ruby, _but because of it_…to leverage what's so amazing about this elegant and delightful language. There's also a saying in the Ruby community: **MINASWAN** (Matz Is Nice And So We Are Nice). It's a community which tries (and hopefully succeeds more often than not) to be welcoming, encouraging, and safe.

Bridgetown also features a frontend-specific layer written in **JavaScript**, the language which powers webpages everywhere. For a long time, JavaScript was known mainly as the language you'd use alongside HTML and CSS for execution within a browser context. But in 2009, along came [Node](https://nodejs.org/), which popularized the idea of running JavaScript software at a command line and on the server. Most frontend-specific build tools are now JavaScript-based, thus requiring Node to be installed.

### The Package Managers

Both Ruby and Node come with their own package managers. A **package manager** lets you specify modular pieces of software your project relies on, along with their versions (and optionally sources, such as GitHub). When you create a Bridgetown site, for example, your site requires the Bridgetown packages to be installed.

![Rubygems logo](/images/rubygems_logo_red.png){:style="width:85px; float:right; margin: 0 0 10px 10px"} Ruby "packages" are called gems, and gems are published on and downloaded from [RubyGems](https://rubygems.org). Ruby's package management system is comprised of two command line tools: `gem` and `bundle` (aka Bundler). When you run `bundle install` after creating or cloning a Ruby app on your computer, that tells Bundler to look at your `Gemfile` and `Gemfile.lock` files, determine the correct dependency tree, and download/install the necessary gems from RubyGems. You can also execute local commands within the correct gem dependency environment by using `bundle exec` (for example, `bundle exec bridgetown build`).

Node likewise comes with its own package manager, `npm`, which will download published JavaScript packages from the [npm registry](https://www.npmjs.com). However, for historical and developer experience (DX) reasons, another commonly-used package manager for Node is called `yarn`. Both Bridgetown and Rails (and a number of other frameworks in various languages) recommend using [Yarn](https://yarnpkg.com) as your package manager, and we include instructions for how to install both Node and Yarn in our installation guides.

Just like Bundler uses `Gemfile`/`Gemfile.lock` for Ruby dependency management, Node/Yarn uses `package.json`/`yarn.lock` for JS dependency management. Typically you never have to interact with the lock files yourself. They're only there to "lock in" very specific versions of all dependencies. You will only need to modify either `Gemfile` or `package.json`.

### The Version Managers

Most people working on multiple software projects at once will quickly run into the massive headache of having to support and utilize multiple versions of language runtimes. For example, you might be using Ruby 2.6 on one project, Ruby 2.7 on another, and Ruby 3.0 on yet another. Or you might be using Node 14 on one project and Node 16 on another project.

Thankfully this is a solved problem when you use a **version manager**. Version managers are responsible for installing (and often compiling ahead of time) the specific languages you need for your various projects. For Ruby, we recommend using [rbenv](https://github.com/rbenv/rbenv) and include those instructions in our installation guides.

Because Bridgetown's use of Node is fairly lightweight, we're not too opinionated about the exact version of Node you use. But if you wish to utilize a version manager for Node as well, we recommend using [nvm](https://github.com/nvm-sh/nvm).

In both cases, you'll add "dot files" to your projects specifying the version of the language you need. For example, saving `ruby-2.7.2` to `.ruby-version` will instruct your Ruby version manager you want to use Ruby 2.7.2. Or saving `14` to `.nvmrc` means you want NVM to use the latest version of the Node 14 releases.

### The Scripts

Oftentimes you want to be able to supply custom scripts in a project to kick off build processes or to interact with tooling or testing in various ways. Yarn makes this easy by looking at the `scripts` section of your `package.json` file. So for example, when you run `yarn webpack-build` in a Bridgetown project, what's really going on is Yarn will execute the `webpack-build` script, which itself says to run the `webpack --mode production` command.

Many Ruby projects rely on a tool called Rake which can run entire tasks (essentially "mini" Ruby programs) defined in a `Rakefile`. In the next release of Bridgetown, we'll be adding **full support for Rake tasks** and migrating some of our own scripts out of `package.json` and into tasks or dedicated commands.

Once that release is available, you'll be able to use "binstubs" — essentially Ruby scripts saved to your project's `bin` folder which automatically instantiate the Bundler environment for you. So instead of typing `bundle exec bridgetown`, you'll be able to type `bin/bridgetown`, and instead of starting Bridgetown's local dev server processes via `yarn start`, you'll instead run `bin/bridgetown start`.

### The Ruby Server

In the currently shipping release of Bridgetown, we use a Ruby-based web server called **WEBrick** to serve up the static pages and files generated by Bridgetown's build process. If you directly run `bundle exec bridgetown serve`, a WEBrick server is spun up and handles all requests. This is largely for historical reasons, and in the next version of Bridgetown, we're making a substantial change and migrating to **Puma**.

Puma is currently the server of choice for the Rails framework, and with good reason. It's extremely fast, well-maintained, and can scale from simple local development all the way to massive production server deployments.

Puma works in concert with **Rack**, a low-level specification and infrastructure for Ruby-powered web stacks. Virtually every modern web framework from Rails to Roda to Sinatra to Hanami sits atop Rack, and one of the amazing things about Rack is you can use multiple frameworks at once! Mount a Sinatra app alongside Rails, mount a Rails app alongside Roda, etc. Rack also supports a broad assortment of "middleware" — plugins which will add functionality to or otherwise affect the request/response cycle of your website.

Switching to Puma + Rack will be a huge win for the Bridgetown codebase and open up all sorts of new opportunities for the platform. Stay tuned.

### The Frontend Tooling

![PostCSS logo](/images/postcss.svg){:style="width:85px; float:right; margin: 0 0 10px 10px"} For the [frontend](/docs/frontend-assets) (CSS, JavaScript, and related assets such as fonts and icons), Bridgetown uses three primary tools:

* **[Webpack](https://webpack.js.org)**: a popular "bundler" and asset pipeline which takes in one or more "entry points" (typically your `frontend/javascript/index.js` file), analyzes the tree of various JS & CSS-related import statements, and outputs a final, compiled bundle of JS and CSS code which your Bridgetown site will load.
* **[esbuild](https://esbuild.github.io)**: a fast JavaScript "transpiler" which will ensure your modern JavaScript code is output in a format consumable by virtually all modern browsers. In the past we used Babel for this task, but esbuild is an order of magnitude faster, and many projects from Rails to Vite to Astro are reworking their frontend infrastructure to leverage esbuild. In the future, we ourselves plan to offer a "lite" frontend pipeline which jettisons Webpack in favor of esbuild only.
* Either **[PostCSS](https://postcss.org)** or **[Sass](https://sass-lang.com)**: Depending on how you set up your project, you'll be using either `postcss` or `sass` to process your CSS files. Sass is a well-known superset of CSS which enjoyed popular appeal for many years, but in recent times PostCSS has arisen as a slick way to utilize upcoming standards-based proposals for CSS itself (such as nesting, advanced color functions, etc.) but transpile them to CSS which works in browsers today. Unless you know you need to use Sass for a particular reason (perhaps to leverage a framework like Bulma or Bootstrap), we recommend people start new projects using PostCSS.

### The Template Languages

![Serbea logo](/images/serbea-logomark.svg){:style="width:85px; float:right; margin: 0 0 10px 10px"} Much of the time as you work on your Bridgetown site, you'll be authoring content in either **Markdown** or **HTML**. [Markdown](https://kramdown.gettalong.org/quickref.html) is a great way to include formatting in your plain text documents whether you're writing a blog post or a portfolio or a marketing page.

Whether using Markdown or HTML to lay out pages and components, you'll often be working within a "template language" — aka a language which lets you augment your markup with statements to insert or process data, loop through data, filter data, render other components, and generally add all the "smarts" you need on any given page.

Bridgetown comes with support for two template languages out of the box, with more available as plugins. These two are **Liquid** and **ERB**.

[Liquid](/docs/liquid), the default option, is a fairly simple (and "safe") template language invented and popularized by Shopify, along with Jekyll (the progenitor of Bridgetown). By using Liquid tags and filters, and by moving repeatable or reusable sections of markup into Liquid components, you can build a fairly sophisticated site in short order.

For more power and a greater "Ruby-like" experience, you can switch to using [ERB](/docs/erb-and-beyond). Just like in Rails and other Ruby frameworks, ERB lets you write actual Ruby code within your HTML and Markdown files, which provides additional flexibility and access to the entire world of gems for advanced data processing. But with great power comes great responsibility, and it's easier to make breaking mistakes when writing ERB (Liquid tends to be more forgiving). Which option is best for your project? It depends mostly on personal preference and which specific features you need.

Other template languages available are [Serbea](https://www.serbea.dev) (a "superset" of ERB which adds back in some of the elegant filtering features provided by Liquid along with other shorthand expressions), [Slim](https://github.com/bridgetownrb/bridgetown-slim), and [Haml](https://github.com/bridgetownrb/bridgetown-haml). And if you _really_ want to go out on a limb, you can even [render Lit components right in your Ruby template files](https://github.com/bridgetownrb/bridgetown-lit-renderer)!

### And the Rest…?

**Whew, that was a lot of terminology!** You'd be forgiven if you have a tough time remembering it all. That's why we're here to help break it all down and provide you with a solid foundation for growth as a web developer. You don't need to use or know about all the options here at once. But it's good to know where to look if you get stuck or when you need to level up your Bridgetown project.

**Still got questions? Feedback?** Please reach out to us on [Twitter](https://twitter.com/bridgetownrb) or [Discord](https://discord.gg/4E6hktQGz4) and let us know how the Bridgetown community can help.
