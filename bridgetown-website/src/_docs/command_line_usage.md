---
order: 4
next_page_order: 4.5
title: Command Line Usage
top_section: Setup
category: cmd_usage
---

The Bridgetown gem makes the `bridgetown` executable available to you in your terminal.

You can use this command in a number of ways:

* `bridgetown new PATH` - Creates a new Bridgetown site with default configuration at specified path. The folders will be created as necessary.
* `bridgetown build` or `bridgetown b` - Performs a one off build of your site to `./output` (by default)
* `bridgetown serve` or `bridgetown s` - Rebuilds your site any time a source file changes and serves it locally
* `bridgetown doctor` - Outputs any deprecation or configuration issues
* `bridgetown clean` - Removes all generated files: destination folder, metadata file,  and Bridgetown caches.
* `bridgetown help` - Shows help, optionally for a given subcommand, e.g. `bridgetown help build`

Typically you'll use `bridgetown serve` while developing locally and `bridgetown build` when you need to generate the site for production.

To change Bridgetown's default build behavior have a look through the [configuration options](/docs/configuration/).
