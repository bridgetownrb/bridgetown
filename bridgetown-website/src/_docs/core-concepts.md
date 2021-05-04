---
order: 4
next_page_order: 4.2
title: Core Concepts
top_section: Setup
category: core_concepts
---

It's easy to get started with Bridgetown, but it helps to have a basic understanding
of a few key aspects of the site build process so you know which tools to use for
the right job. The very fact that you "run a build" and not load up an application
server to host and deploy your website is due to the fact that Bridgetown is a
[Jamstack web framework](/docs/jamstack/). This means the website your visitors
will ultimately engage with is a "snapshot in time"—the product of a build process.
How does that process work? Let's find out!

## The Build Process

There's a relatively linear process which occurs every time you run a [build command](/docs/command-line-usage):

1. First, Bridgetown loads its internal Ruby APIs as well as any Ruby gems specified in the `bridgetown-plugins` group of your `Gemfile`.
1. Next, Bridgetown looks for a [configuration](/docs/configuration) file in your current working directory and uses that to instantiate a `site` object.
1. After loading the configuration, Bridgetown prepares the `site` object for loading the various types of [content in your site repository](/docs/structure), starting with [custom plugins](/docs/plugins) in the `plugins` folder.
1. Plugins are then granted the ability to [generate new content programmatically](/docs/plugins/external-apis) and define other features such as [Liquid tags](/docs/plugins/tags) (aka "shortcodes"). This is the point when you'd create blog posts, collection documents, etc. from data provided by an external API for example.
1. Once plugins (if any) have loaded, Bridgetown starts systematically reading in files from the source folder (typically `src`):
  * [Layouts](/docs/layouts)
  * [Liquid Components](/docs/components) (**new** in Bridgetown 0.15)
  * [Data files](/docs/datafiles)
  * [Static files](/docs/static_files)
  * [Pages](/docs/pages)
  * [Posts](/docs/posts)
  * [Collection documents](/docs/collections)
  * And starting with Bridgetown 0.14, gem-based plugins have the ability to supply their own layouts, components, pages, and static files via [Source Manifests](/docs/plugins/source-manifests).
1. Once all of the data structures for the entire website are in place, Bridgetown __renders__ all relevant content objects to prepare them for final output. This is when documents are placed within layouts, [Front Matter](/docs/front-matter) variables are made available to templates, any [Liquid tags and filters](/docs/liquid) are processed, formats like [Markdown](https://kramdown.gettalong.org/quickref.html) are converted to HTML, and generally everything is finalized in its proper output format (HTML, JSON, images, PDFs, etc.).
1. The final step is to write everything to the destination folder (typically `output`). If all has gone well, that folder will contain a complete, fully-functioning website [which can be deployed](/docs/deployment) to any basic HTTP web server.

Normally during development, you will be running a local dev server, which means
every time you change a file (update a blog post, edit a template, replace an image
file, fix a bug in a custom plugin, etc.), that _entire build process_ is run
through again.

For small-to-medium sites and on reasonably modern hardware, this typically happens
in only a few seconds or less. For really large sites with tens of thousands of
pages, or if many external API calls are involved, build processes can slow down
substantially. There are technical solutions to many of these slowdowns, which can
range from caching API data between builds to switching on [incremental build regeneration](/docs/configuration/incremental-regeneration),
but there are challenges with such approaches. Nevertheless, improving build time
is a major goal of the Bridgetown core team as we look to the future.

## The Webpack Build Process

There's one aspect of the build process overlooked above: the compiling,
compressing, and bundling of [frontend assets](/docs/frontend-assets) like
JavaScript, CSS, web fonts, and so forth.

When using Bridgetown's built-in `yarn start` or `yarn deploy` commands,
essentially _two_ build processes are kicked off: the Webpack build process and the
Bridgetown build process. The two align when something magical happens.

1. Webpack will conclude its build process by exporting a `manifest.json` file to the hidden `.bridgetown-webpack` folder. This manifest lists the exact, fingerprinted filenames of the compiled and bundled JS and CSS output files.
1. Bridgetown, using the `webpack_path` Liquid tag, monitors that manifest, and whenever it detects a change it will regenerate the site to point to those bundled output files.
1. This way, your website frontend and the HTML of your generated static site are always kept in sync (as long as you use the provided Yarn scripts!).

## Adding Extra Features to Your Site

In addition to the work you do yourself to code, design, and publish your website,
there are ways you can enhance your site by installing third-party plugins or
applying automations. These may provide new features, themes, or software
configurations in useful ways. Some examples:

* Add instant search to your site with the [bridgetown-quick-search](https://github.com/bridgetownrb/bridgetown-quick-search) plugin
* Include inline SVG images with the [bridgetown-inline-svg](https://github.com/andrewmcodes/bridgetown-inline-svg) plugin
* Start your site off with a clean, professional design via the [Bulmatown](https://github.com/whitefusionhq/bulmatown) theme and Bulma CSS framework

You can discover links to these and many more in our [Plugins directory](/plugins/).

## What to Learn Next

There is detailed documentation available about each and every step mentioned
above, so feel free to poke around and read up on the topics which interest you the
most. And as always, if you get stuck or have follow-up questions, just hop in one
of our [community channels](/docs/community) and a friendly Bridgetowner will
endeavor to help you out!
