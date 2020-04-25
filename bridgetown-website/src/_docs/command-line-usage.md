---
order: 4
next_page_order: 4.5
title: Command Line Usage
top_section: Setup
category: cmd_usage
---

The Bridgetown gem makes the `bridgetown` executable available to you in your terminal.

You can use this command in a number of ways:

* `bridgetown new PATH` - Creates a new Bridgetown site with a default configuration
  at specified path, along with a typical site folder structure and starter
  templates.
* `bridgetown build` or `bridgetown b` - Performs a single build of your site to
  the `output` folder (by default). Add the `-w` flag to also regenerate the site
  whenever a source file changes.
* `bridgetown serve` or `bridgetown s` - Regenerates your site any time a source file
  changes and serves it locally (http://127.0.0.1:4000 by default).
* `bridgetown console` or `bridgetown c` - Opens up an IRB console and lets you
  inspect your site configuration and content "under the hood" using
  Bridgetown's native Ruby API.
* `bridgetown help` - Shows help, optionally for a given subcommand, e.g. `bridgetown help build`
* `bridgetown doctor` - Outputs any deprecation or configuration issues.
* `bridgetown clean` - Removes all generated files: destination folder, metadata file,  and Bridgetown caches.

Typically you'll use `bridgetown serve` while developing locally and
`bridgetown build` when you need to generate the site for production*.

To change Bridgetown's default build behavior have a look through the [configuration options](/docs/configuration/).

## Yarn Scripts

Bridgetown also comes with some handy Yarn scripts to help spin up both Bridgetown
and Webpack during development, as well as use Browsersync to provide live-reload
functionality. Take a look at the `scripts` configuration in `package.json`, as well as
the `start.js` and `sync.js` Javascript files.

\*To build your site for production, you can run `yarn deploy` so that all the
Webpack assets get built alongside the published Bridgetown output. If you need to add
an extra step to copy `output` to a web server, putting that in the `yarn deploy` script
is a good way to go.
