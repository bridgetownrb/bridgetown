---
order: 20
title: Core Concepts
top_section: Introduction
category: core_concepts
next_page_order: 25
---

It's easy to get started with Bridgetown, but it helps to have a basic understanding of a few key aspects of the site build process so you know which tools to use for the right job. Websites using Bridgetown are built and deployed as atomic artifacts, but they can optionally provide dynamic routes via a secondary server process. Frameworks like this are sometimes referred to as Jamstack frameworks. This means the website your visitors will ultimately engage with was largely produced as a "snapshot in time"—the product of Bridgetown's build process. How does that process work? Let's find out!

## The Build Process

There's a relatively linear process which occurs every time you run a [build command](/docs/command-line-usage):

1. First, Bridgetown loads its internal Ruby APIs as well as any Ruby gems specified in the `bridgetown-plugins` group of your `Gemfile`.
1. Next, Bridgetown looks for a [configuration](/docs/configuration) file in your current working directory and uses that to instantiate a `site` object.
1. After loading the configuration, Bridgetown prepares the `site` object for loading the various types of [content in your site repository](/docs/structure), starting with [custom plugins](/docs/plugins) in the `plugins` folder.
1. Plugins are then granted the ability to [generate new content programmatically](/docs/plugins/external-apis) and define other features such as [Liquid tags](/docs/plugins/tags) or [Ruby helpers](/docs/plugins/helpers) (aka "shortcodes"). This is the point when you'd create blog posts and other resources from data provided by an external API for example.
1. Once plugins (if any) have loaded, Bridgetown starts systematically reading in files from the source folder (typically `src`):
  * [Layouts](/docs/layouts)
  * [Components](/docs/components)
  * [Data files](/docs/datafiles)
  * [Static files](/docs/static-files)
  * [Resources](/docs/resources)
  * Any gem-based plugins which supply their own layouts, components, and content via [Source Manifests](/docs/plugins/source-manifests).
1. Once all of the data structures for the entire website are in place, Bridgetown __renders__ all relevant content objects to prepare them for final output. This is when [Front Matter](/docs/front-matter) variables are made available to templates, any [Liquid](/docs/template-engines/liquid) or [Ruby](/docs/template-engines/erb-and-beyond) templates are processed, formats like [Markdown](https://kramdown.gettalong.org/quickref.html) are converted to HTML, resources are placed within layout templates, and generally everything is finalized in its proper output format (HTML, JSON, images, PDFs, etc.).
1. The final step is to write everything to the destination folder (typically `output`). If all has gone well, that folder will contain a complete, fully-functioning website [which can be deployed](/docs/deployment) to any basic HTTP web server.

Normally during development, you will be running a local dev server, which means
every time you change a file (update a blog post, edit a template, replace an image
file, fix a bug in a custom plugin, etc.), that _entire build process_ is run
through again.

For small-to-medium sites and on reasonably modern hardware, this typically happens
in only a few seconds or less. For really large sites with tens of thousands of
pages, or if many external API calls are involved, build processes can slow down
substantially. There are technical solutions to many of these slowdowns, which can
range from caching API data between builds to limiting the number of files built in development.
Improving build time is a major goal of the Bridgetown core team as we look to the future.

## The Frontend Build Process

There's one aspect of the build process overlooked above: the compiling,
compressing, and bundling of [frontend assets](/docs/frontend-assets) like
JavaScript, CSS, web fonts, and so forth.

When using Bridgetown's built-in `start` or `deploy` commands,
essentially _two_ build processes are kicked off: the frontend build process (either esbuild or Webpack) and the Bridgetown build process. The two align when something magical happens.

1. esbuild/Webpack will conclude its build process by exporting a `manifest.json` file to the hidden `.bridgetown-cache` folder. This manifest lists the exact, fingerprinted filenames of the compiled and bundled JS and CSS output files.
1. Bridgetown, using the `asset_path` Liquid tag/Ruby helper, monitors that manifest, and whenever it detects a change it will regenerate the site to point to those bundled output files.
1. This way, your website frontend and the HTML of your generated static site are always kept in sync.

## Adding Extra Features to Your Site

In addition to the work you do yourself to code, design, and publish your website,
there are ways you can enhance your site by installing third-party plugins or
applying automations. These may provide new features, themes, or software
configurations in useful ways. Some examples:

* Add instant search to your site with the [bridgetown-quick-search](https://github.com/bridgetownrb/bridgetown-quick-search) plugin
* Include inline SVG images with the [bridgetown-svg-inliner](https://github.com/ayushn21/bridgetown-svg-inliner) plugin
* Start your site off with a clean, professional design via the [Bulmatown](https://github.com/whitefusionhq/bulmatown) theme and Bulma CSS framework

You can discover links to these and many more in our [Plugins directory](/plugins/).

## Server-Side Rendering and Dynamic Routes

For most content-rich websites intended for marketing, educational, or publishing purposes (blogs, etc.), a statically-built and deployed site may be all you need. But there may be times when you need a real backend running for your site, either to provide API endpoints your principal pages can communicate with via JavaScript, or to offer actual routes that are fully SSR'd (Server-Side Rendered).

Bridgetown 1.0 ships with an early look at a [full SSR pipeline powered by the Roda web toolkit](/docs/routes). Roda, like Rails or Sinatra, takes full advantage of Ruby's Rack ecosystem and offers a minimalist yet elegant DSL (Domain-Specific Language) for defining and handling routes via a "routing tree" as well as processing request/response cycles. Accepting form data or JSON payloads is a snap, and there's even a core plugin you can configure to enable dynamic, file-based routing with all of Bridgetown's template engines and component rendering at your disposal.

## What to Learn Next

There is detailed documentation available about each and every step mentioned
above, so feel free to poke around and read up on the topics which interest you the
most. And as always, if you get stuck or have follow-up questions, just hop in one
of our [community channels](/community) and a friendly Bridgetowner will
endeavor to help you out!
