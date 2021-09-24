---
title: Let’s Talk Bridgetown Terminology!
subtitle: We throw around a lot of terms, many of which may be unfamiliar at first glance. Time to break it all down!
author: jared
category: feature
---

As you read through our documentation or spend time in our community chat, you'll discover we tend to throw around a lot of terms, many of which may be unfamiliar at first glance. It's easy to feel overwhelmed with all the different tools and options available. But never fear, it's time to break it all down!

### The Languages

Bridgetown is mostly written in **Ruby**, a programming language first invented by [Yukihiro Matsumoto](https://en.wikipedia.org/wiki/Yukihiro_Matsumoto), or "Matz" as he is commonly known, back in 1995. Ruby has been called a language which optimizes for "programmer happiness" — and that's certainly been our experience over the years. Ruby first saw widespread adoption in large part due to the rise of the **Ruby on Rails** web framework, but Ruby is far more applicable than just as the foundation of the Rails stack. We're constantly trying to find ways to make Bridgetown better not in spite of Ruby, _but because of it_…to leverage what's so amazing about this elegant and delightful language.

Bridgetown also has a frontend-specific layer written in **JavaScript**, the language which powers webpages everywhere. For a long time, JavaScript was known mainly as a language you'd use alongside HTML and CSS for execution within a browser context. Then along came **Node** in 2009, which popularized the idea of running JavaScript software at a command line and on the server. Most frontend-specific build tools are now JavaScript-based, thus requiring Node to be installed.

### The Package Managers

Both Ruby and Node come with their own package managers. A package manager lets you specify modular pieces of software your project relies on, along with their versions (and optionally sources, such as GitHub). When you create a Bridgetown site, for example, your site requires the Bridgetown package to be installed.

Ruby "packages" are called gems, and gems are published on and downloaded from [RubyGems](https://rubygems.org). Ruby's package management system is comprised of two command line tools: `gem` and `bundle` (aka Bundler). When you run `bundle install` after creating or cloning a Ruby app on your computer, that tells Bundler to look at your `Gemfile` and `Gemfile.lock` files, figure out the correct dependency tree, and download/install the necessary gems from RubyGems. You can also execute local commands within the correct gem dependency environment by using `bundle exec` (for example, `bundle exec bridgetown build`).

Node likewise comes with its own package manager, `npm`, which will download published JavaScript packages from the [npm registry](https://www.npmjs.com). However, for historical and "developer experience" (DX) reasons, another commonly-used package manager for Node is called `yarn`. Both Bridgetown and Rails (and a number of other frameworks in various languages) recommend using Yarn as your package manager, and we include instructions for how to install both Node and Yarn in our installation guides.

Just like Bundler uses `Gemfile`/`Gemfile.lock` for Ruby dependency management, Node/Yarn uses `package.json`/`yarn.lock` for JS dependency management. Typically you never have to interact with the lock files. They're only there to "lock in" very specific versions of all dependencies. You yourself will only need to modify either `Gemfile` or `package.json`.

### The Version Managers

Most people working on multiple software projects at once will quickly run into the massive headache of having to support and utilize multiple versions of language runtimes. For example, you might be using Ruby 2.6 on one project, Ruby 2.7 on another, and Ruby 3.0 on yet another. Or you might be using Node 14 on one project and Node 16 on another project.

Thankfully, this is a solved problem when you use a **version manager**. Version managers are responsible for installing (and often compiling ahead of time) the specific languages you need for your various projects. For Ruby, we recommend using [rbenv](https://github.com/rbenv/rbenv) and include those instructions in our installation guides.

Because Bridgetown's use of Node is fairly lightweight, we're not too opinionated about the exact version of Node you use. But if you wish to utilize a version manager for Node as well, we recommend using [nvm](https://github.com/nvm-sh/nvm).

In both cases, you add "dot files" to your projects specifying the version of the language you need. For example, saving `ruby-2.7.2` to `.ruby-version` will instruct your Ruby version manager you want to use Ruby 2.7.2. Or saving `14` to `.nvmrc` means you want NVM to use the latest release of the Node 14 line.

### The Scripts

Oftentimes you want to be able to supply custom scripts in a project to kick off build processes or interact with tooling or testing in various ways. Yarn makes this easy by looking at the `scripts` section of your `package.json` file. So for example, when you run `yarn webpack-build` in a Bridgetown project, what's really going on is Yarn will execute the `webpack-build` script, which itself says to run the `webpack --mode production` command.

Many Ruby projects rely on a tool called Rake which can run entire tasks (essentially "mini" Ruby programs) defined in a `Rakefile`. In the next release of Bridgetown, we'll be adding full support for Rake tasks and migrating some of our own scripts out of `package.json` and into tasks or dedicated commands.

Once that release is out, you'll be able to use "binstubs" — essentially Ruby scripts saved to your project's `bin` folder which automatically instantiate the Bundler environment for you. So instead of using `bundle exec bridgetown`, you'll be able to type `bin/bridgetown`, and instead of starting Bridgetown's local dev server processes via `yarn start`, you'll instead run `bin/bridgetown start`.

### The Ruby Server

In the currently shipping release of Bridgetown, we use a Ruby-based web server called **WEBrick** to serve up the static pages and files generated by Bridgetown's build process. If you directly run `bundle exec bridgetown serve`, a WEBrick server is spun up and handles all requests. This is largely for historical reasons, and in the next version of Bridgetown, we're making a substantial change and migrating to **Puma**.

Puma is currently the server of choice for the Rails framework, and with good reason. It's extremely fast, well-maintained, and can scale from simple local development all the way to massive production server deployments.

Puma works in concert with **Rack**, a low-level specification and infrastructure for Ruby-powered web stacks. Virtually every modern web framework from Rails to Roda to Sinatra to Hanami sits atop Rack, and one of the amazing things about Rack is you can use multiple frameworks at once! Mount a Sinatra app alongside Rails, mount a Rails app alongside Roda, etc. Rack also supports a broad assortment of "middleware" — plugins which will add functionality to or otherwise affect the request/response cycle of your website.

Switching to Puma + Rack will be a huge win for the Bridgetown codebase and open up all sorts of new opportunities for the platform. Stay tuned.

### The Frontend Tooling

For the frontend (CSS, JavaScript, and related assets such as fonts and icons), Bridgetown uses three primary tools:

* **Webpack**: a popular "bundler" and asset pipeline which takes in one or more "entry points" (typically your `frontend/javascript/index.js` file), analyze the tree of various JS & CSS-related import statements, and output a final, compiled bundle of JS and CSS code which your Bridgetown site will load.
* **esbuild**: a fast JavaScript "transpiler" which will ensure your modern JavaScript code is output in a format consumable by virtually all modern browsers. In the past we used Babel for this task, but esbuild is an order of magnitude faster, and many projects from Rails to Vite to Astro are reworking their frontend infrastructure to leverage esbuild. In the future, we ourselves may offer a "lite" frontend pipeline which jettisons Webpack in favor of esbuild only.
* Either **postcss** or **sass**: Depending on how you set up your project, you'll be using either `postcss` or `sass` to process your CSS files. Sass is a well-known superset of CSS which enjoyed popular appeal for many years, but in recent times PostCSS has arisen as a slick way to utilize upcoming standards-based proposals for CSS itself (such as nesting, advanced color functions, etc.) but transpile them to CSS which works in browsers today. Unless you know you need to use Sass for a particular reason (perhaps to leverage a framework like Bulma or Bootstrap), we recommend people start new projects using PostCSS.

### The Template Languages

Much of the time as you work on your Bridgetown site, you'll be authoring content in either **Markdown** or **HTML**. [Markdown](https://kramdown.gettalong.org/quickref.html) is a great way to include formatting in your plain text documents whether you're writing a blog post or a portfolio or a marketing page.

Whether using Markdown or HTML to lay out pages and components, you'll often be working within a "template language" — aka a language which lets you augment your markup with statements to insert or process data, loop through data, filter data, render other components, and generally add all the "smarts" you need on any given page.

Bridgetown comes with support for two template languages out of the box, with more available as plugins. These two are **Liquid** and **ERB**.

Liquid, the default option, is a fairly simple (and "safe") template language invented and popularized by Shopify, along with Jekyll (the progenitor of Bridgetown). By using Liquid tags and filters, and by moving repeatable or reusable sections of markup into Liquid components, you can build a fairly sophisticated site in short order.

For more power and a greater "Ruby-like" experience, you can switch to using ERB. Just like Rails and other Ruby frameworks, ERB lets you write actual Ruby code within your HTML and Markdown files, which provides additional flexibility and access to the entire world of gems for advanced data processing. But with great power comes great responsibility, and it's easier to make breaking mistakes when writing ERB (Liquid tends to be more forgiving). Which option is best for your project? It's up to you.

Other template languages available are Serbea (a superset of ERB which adds back in some of the elegant filtering features provided by Liquid along with other shorthand expresssions), Slim, and Haml. Does this make Bridgetown the most flexible SSG (Static Site Generator) in the world when it comes to template language support? Certainly seems like a possibility.


