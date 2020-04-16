# master

  * Add back working feature tests for basic pagination
  * Convert to Ruby 1.9+ `symbol: value` hash syntax
  * Add [Swup](https://swup.js.org) to website for some slick transitions
  * Add "where_query" feature to Paginate. For example. specify `where_query: [author, sandy]` in the pagination YAML to filter by that front matter key.
  * Update the Jamstack page in the docs.

# 0.8.1 / 2020-04-14

  * Fix bug where paginator wouldn't properly convert Markdown templates

# 0.8.0 / 2020-04-14

  * Add Bridgetown::Paginate gem to monorepo
  * Add CI build workflow via GitHub actions
  * Clean up Rake tasks
  * Add documentation around gem releases and contributing PRs

# 0.7.0 / 2020-04-12

  * Moved the default plugins folder from `src/_plugins` to simply `plugins`
  * Remove `gems` and `plugins` keys from configuration
  * Move the cache and metadata folders to the root dir
  * Define a default data file for site metadata: `src/_data/site_metdata.yml`
    that's accessible via `{{ site.metadata.title }}` (for example)
  * Add relevant changes to site template for `bridgetown new`
  * Continue work on repo cleanup and documentation

# 0.6.0 / 2020-04-09

  * Add `bridgetown console` command to invoke IRB with the current site (similar to the Rails console command). Plugins, gems, will be loaded, etc.

# 0.5.0 / 2020-04-07

  * Remove `em-websocket` dependency.
  * Change _config.yml to bridgetown.config.yml (but _config.yml will still work for compatibility purposes).
  * New Bridgetown logo and further Bridgetown URL updates.
  * Many new and improved docs.

# 0.4.0 / 2020-04-05

  * Added a `component` Liquid tag which extends the functionality of include tags.
  * Added a new `bridgetown-website` project to the repo, which of course is a Bridgetown site and will house the homepage, documentation, etc.

# 0.3.0 / 2020-04-05

  * Moved all Bridgetown code to `bridgetown-core`, the idea being this will now be a monorepo housing Core plus a few other official gems/projects as time goes on. Users will install the `bridgetown` gem which in turns installs `bridgetown-core` as a dependency.

# 0.2.0 / 2020-04-04

  * Completed comprehensive code audio and changed or removed features no
    longer required for the project. Fixed and successfully ran test suite
    accordingly.

# 0.1.0 / 2020-04-02

  * First version after fork from pre-released Jekyll 4.1
