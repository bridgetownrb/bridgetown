# master

# 0.10.2 / 2020-04-19

**Automatic Yarn Step for New Plugins**

Now with Gem-based plugins for Bridgetown, all you need to do is add `yarn-add`
metadata matching the NPM package name and keep the version the same as the Gem
version. For example:

```ruby
  spec.metadata = { "yarn-add" => "my-awesome-plugin@#{MyAwesomePlugin::VERSION}" }
```

With that bit of metadata, Bridgetown will know always to look for that package in
the users' `package.json` file when they load Bridgetown, and it will trigger a
`yarn add` command if the package and exact version number isn't present.

# 0.10.1 / 2020-04-18

Add `{% webpack_path [js|css] }` tag which pulls in the Webpack manifest and finds
the hashed output bundles. Also works in concert with the Watcher so every time
Webpack rebuilds the bundles, Bridgetown regenerates the site.

[#6](https://github.com/bridgetownrb/bridgetown/pull/6)

# 0.10.0 / 2020-04-17

**Switch gears on _experimental_ component functionality.**

Going with a new `rendercontent` tag instead of `component`. It is based on
Shopify's new Render tag which recently got introduced to Liquid. Note that the
feature hasn't been officially released via the Liquid gem, so we need to use the
master branch that's been forked on GitHub with a higher version number).

[#5](https://github.com/bridgetownrb/bridgetown/pull/5)

# 0.9.0 / 2020-04-16

  * Update table styling in Documentation
  * Now showing the plugins_dir in log output if it's present
  * With the Posts Reader changes, now you can add a Front Matter Default of
    `_posts/drafts` having `published: false`, put a bunch of draft posts in
    `_posts/drafts` and you're done!
  * New `-U` flag makes it easier to specify generating `published: false` docs.
  * The Posts Reader has been reworked so that files with valid front matter can
    be read in even if there's no YYYY-MM-DD- at the beginning. In addition, static
    files are also supported, which means if you can create a folder (`inlinefiles`),
    drop a post in along with a bunch of images, and use `![alt](some-image.jpg)`
    relative paths, it'll work! Big improvement to Markdown authoring. (You'll need
    to use a permalink in a specific manner though, e.g.
    `permalink: /inlinefiles/:title:output_ext`)
    If you need a static file not to get copied to the destination, just add an
    `_` at the beginning and it'll get ignored.
  * Collections no longer allow displaying a full server file path via Liquid.
  * `{{ page.collection }}` now returns a CollectionDrop, not the label of
    the collection. Using the `jsonify` filter on a document however still returns
    just the label for the `collection` key.
  * Add favicon to website
  * Add mobile improvements to website
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
