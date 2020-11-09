# main

# 0.18.4 / 2020-11-05

* Bugfix: reset payload for each Liquid template conversion
* Change site.layouts hash to dot access

# 0.18.3 / 2020-11-01

* Bugfix: For template engine converters, set template_engine frontmatter automatically [#177](https://github.com/bridgetownrb/bridgetown/pull/177) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.18.2 / 2020-10-30

* Bugfix: Resolve bug in converter error notifications

# 0.18.1 / 2020-10-29

* Bugfix: Use capture helper for liquid_render [#174](https://github.com/bridgetownrb/bridgetown/pull/174) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.18.0 / 2020-10-29

* Configurable template engines on a per-site or per-document basis [#157](https://github.com/bridgetownrb/bridgetown/pull/157) ([jaredcwhite](https://github.com/jaredcwhite))
  * Set a `template_engine` key in your config file. The default is assumed to be liquid, but you can change it to `erb` (or other things in the future as this gets rolled out). Once that is set, you don't even have to name all your ERB files with an `.erb` extension—it will process even `.html.`, `.md`, `.json`, etc. It also means Liquid won't try to "preprocess" any ERB files, etc.
  * Regardless of what is configured site-wide, you can also set the `template_engine` in front matter (whether that's in an individual file or using front matter defaults), allowing you to swap out template engines wherever it's needed.
  * Front matter defaults support setting `template_engine` to none or anything else for a part of the source tree.
  * Liquid pages/layouts with a `.liquid` extension are processed as Liquid even if the configured engine is something else.
  * **Breaking change:** previously it was possible in Liquid for a child layout to set a front matter variable and a parent layout to access the child layout's variable value, aka `{{ layout.variable_from_child_layout }}`. That's no longer the case now…each layout has access to only its own front matter data.
  * **Breaking change:** a few pre-render hooks were provided access to Liquid's global payload hash. That meant they could alter the hash and thus the data being fed to Liquid templates. The problem is that there was no visibility into those changes from any other part of the system. Plugins accessing actual page/layout/site/etc. data wouldn't pick up those changes, nor would other template engines like ERB. Now if a hook needs to alter data, it needs to alter actual Ruby model data, and Liquid's payload should always reflect that model data.
* Add render method for Ruby templates [#169](https://github.com/bridgetownrb/bridgetown/pull/169) ([jaredcwhite](https://github.com/jaredcwhite))
  * Add Zeitwerk loaders for component folders (any `*.rb` file will now be accessible from Ruby templates). _Note:_ Zeitwerk will not load classes from plugins if they're already present in the source folder, so if you want a component to "reopen" a class from a plugin, you'll need to `require` the plugin class explicitly in your local component.
  * Allow ERB capture to pass object argument to its block.
  * **Breaking change:** the previous `<%|= output_block do %>…<%| end %>` block style is out in favor of: `<%= output_block do %>…<% end %>`, so you don't have to change a thing coming from Rails. _Note:_ if you're coming from Middleman where blocks output by default without `<%=`, you'll need to switch to Rails-style block expressions.
  * **Breaking change:** the `markdownify` helper in ERB now just returns a string rather than directly outputting to the template, so use `<%= markdownify do %>…<% end %>`.
* Site documents array should exclude static files [#168](https://github.com/bridgetownrb/bridgetown/pull/168) ([jaredcwhite](https://github.com/jaredcwhite))
* Obfuscate link filter [#167](https://github.com/bridgetownrb/bridgetown/pull/167) ([julianrubisch](https://github.com/julianrubisch))
* Add link/url_for and link_to helpers [#164](https://github.com/bridgetownrb/bridgetown/pull/164) ([jaredcwhite](https://github.com/jaredcwhite))
* False value in front matter is now supported to ensure no layout is rendered [#163](https://github.com/bridgetownrb/bridgetown/pull/163) ([jaredcwhite](https://github.com/jaredcwhite))
* Support per-document locale permalinks and config [#162](https://github.com/bridgetownrb/bridgetown/pull/162) ([jaredcwhite](https://github.com/jaredcwhite))
  * This isn't yet documented because an even more comprehensive i18n solution and announcement is forthcoming.
* Add blank src/images folder [#172](https://github.com/bridgetownrb/bridgetown/pull/172) ([jaredcwhite](https://github.com/jaredcwhite))
* chore: Prototype pages optimizations and improvements to YARD docs [#171](https://github.com/bridgetownrb/bridgetown/pull/171) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.17.1 / 2020-10-02

* Use HashWithDotAccess::Hash for all data/config hashes [#158](https://github.com/bridgetownrb/bridgetown/pull/158) ([jaredcwhite](https://github.com/jaredcwhite))
* Add view reference to template helpers object [#153](https://github.com/bridgetownrb/bridgetown/pull/153) ([jaredcwhite](https://github.com/jaredcwhite))
* Support a _pages folder in the source tree [#151](https://github.com/bridgetownrb/bridgetown/pull/151) ([jaredcwhite](https://github.com/jaredcwhite))
* Add reading_time filter/helper [#150](https://github.com/bridgetownrb/bridgetown/pull/150) ([jaredcwhite](https://github.com/jaredcwhite))
* Rename pager variable to paginator [#148](https://github.com/bridgetownrb/bridgetown/pull/148) ([ParamagicDev](https://github.com/ParamagicDev) & [jaredcwhite](https://github.com/jaredcwhite))
* Add Class Map helper and usage info in docs [#147](https://github.com/bridgetownrb/bridgetown/pull/147) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.17.0 "Mount Scott" / 2020-09-17

* Helper DSL for plugins (similar to the Liquid Filter DSL) [#135](https://github.com/bridgetownrb/bridgetown/pull/135) ([jaredcwhite](https://github.com/jaredcwhite))
* Process data cascade for folder-based frontmatter defaults [#139](https://github.com/bridgetownrb/bridgetown/pull/139) ([jaredcwhite](https://github.com/jaredcwhite))
* Execute block-based filters within object scope [#142](https://github.com/bridgetownrb/bridgetown/pull/142) ([jaredcwhite](https://github.com/jaredcwhite))
* Provide a Liquid find tag as easier alternative to where_exp [#101](https://github.com/bridgetownrb/bridgetown/pull/101) ([jaredcwhite](https://github.com/jaredcwhite))
* First pass at implementing site locales and translations [#131](https://github.com/bridgetownrb/bridgetown/pull/131) ([jaredcwhite](https://github.com/jaredcwhite))
* Add international character slug improvements [#138](https://github.com/bridgetownrb/bridgetown/pull/138) ([jaredcwhite](https://github.com/jaredcwhite) & [swanson](https://github.com/swanson))
* Switch to processing Ruby front matter by default [#136](https://github.com/bridgetownrb/bridgetown/pull/136) ([jaredcwhite](https://github.com/jaredcwhite))
* Switch from AwesomePrint to AmazingPrint [#127](https://github.com/bridgetownrb/bridgetown/pull/127) ([jaredcwhite](https://github.com/jaredcwhite))

# Website updates

* Fix filter plugin doc [#130](https://github.com/bridgetownrb/bridgetown/pull/130) ([julianrubisch](https://github.com/julianrubisch))
* Try out a couple of improvements for Lighthouse score [#128](https://github.com/bridgetownrb/bridgetown/pull/128) ([jaredcwhite](https://github.com/jaredcwhite))
* Adding netlify.toml to add caching & hint headers [#112](https://github.com/bridgetownrb/bridgetown/pull/112) ([MikeRogers0](https://github.com/MikeRogers0))

# 0.16.0 "Crystal Springs" / 2020-07-28

* Final release of 0.16! Yipee yay! Keep reading for what's new since 0.15.

# 0.16.0.beta2 / 2020-07-24

(`0-16-stable` branch)

* Fix the "add_yarn_for_gem" action [#114](https://github.com/bridgetownrb/bridgetown/pull/114) ([jaredcwhite](https://github.com/jaredcwhite))
* Call GitHub API to determine default branch name [#115](https://github.com/bridgetownrb/bridgetown/pull/115) ([jaredcwhite](https://github.com/jaredcwhite))
* Add capture helper to ERB templates
* Switch to Erubi for ERB template parsing
* Move webpack parsing code to the Utils module and enable for ERB templates [#105](https://github.com/bridgetownrb/bridgetown/pull/105) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.16.0.beta1 / 2020-07-16

(`0-16-stable` branch)

* Improve handling of Webpack manifest errors [#96](https://github.com/bridgetownrb/bridgetown/pull/96) ([ParamagicDev](https://github.com/ParamagicDev))
* Add a class_map Liquid tag [#99](https://github.com/bridgetownrb/bridgetown/pull/99) ([ParamagicDev](https://github.com/ParamagicDev))
* Update pagination documentation [#98](https://github.com/bridgetownrb/bridgetown/pull/98) ([andrewmcodes](https://github.com/andrewmcodes))
* Add ERB template support (with Slim/Haml coming as additional plugins) [#79](https://github.com/bridgetownrb/bridgetown/pull/79) ([jaredcwhite](https://github.com/jaredcwhite))
* Add/update Yard documentation for Site concerns [#85](https://github.com/bridgetownrb/bridgetown/pull/85) ([ParamagicDev](https://github.com/ParamagicDev))
* Resolve deprecation warnings for Ruby 2.7 [#92](https://github.com/bridgetownrb/bridgetown/pull/92) ([jaredcwhite](https://github.com/jaredcwhite))
* Switched the default branch from master to main
* Remove the Convertible concern and refactor into additional concerns [#80](https://github.com/bridgetownrb/bridgetown/pull/80) ([jaredcwhite](https://github.com/jaredcwhite))
* Reducing animation for users who prefer reduced motion [#84](https://github.com/bridgetownrb/bridgetown/pull/84) ([MikeRogers0](https://github.com/MikeRogers0))

# 0.15.0 "Overlook" / 2020-06-18

* Final release of 0.15! Woo hoo! Keep reading for what's new since 0.14

# 0.15.0.beta4 / 2020-06-15

(`0-15-stable` branch)

* Add documentation for Cypress testing [#75](https://github.com/bridgetownrb/bridgetown/pull/75) ([ParamagicDev](https://github.com/ParamagicDev))
* Add missing related_posts to Document drop [#78](https://github.com/bridgetownrb/bridgetown/pull/78) ([jaredcwhite](https://github.com/jaredcwhite))
* Use AwesomePrint gem for console [#76](https://github.com/bridgetownrb/bridgetown/pull/76) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.15.0.beta3 / 2020-06-05

(`0-15-stable` branch)

* New documentation on plugin development (including `bridgetown plugins new`), themes, automations, Liquid components, etc. [now on beta website](https://beta.bridgetownrb.com). Beta site also showcases the upcoming quick search plugin which will be made available to all site devs.
* Optimizations made internally to the Bridgetown test suite.
* Bridgetown website experiment with test suite [#69](https://github.com/bridgetownrb/bridgetown/pull/69) ([jaredcwhite](https://github.com/jaredcwhite))
* Fix for GitHub branch URLs in automations [#66](https://github.com/bridgetownrb/bridgetown/pull/66) ([ParamagicDev](https://github.com/ParamagicDev))
* Migrate CLI from Mercenery to Thor and Enable Automations [#56](https://github.com/bridgetownrb/bridgetown/pull/56) ([jaredcwhite](https://github.com/jaredcwhite))
* First implementation of Liquid Components as well as a preview tool on the Bridgetown website [#26](https://github.com/bridgetownrb/bridgetown/pull/26) ([jaredcwhite](https://github.com/jaredcwhite))
* Deprecate the include tag and standardize around the render tag [#46](https://github.com/bridgetownrb/bridgetown/pull/46) ([jaredcwhite](https://github.com/jaredcwhite))

# 0.14.1 / 2020-05-23

* Patch to fix PluginManager `yarn add` bug when there is no `dependencies` key in `package.json`

# 0.14.0 "Hazelwood" / 2020-05-17

* Use `liquid-render-tag` backport gem and remove references to temporary GitHub fork of Liquid [#52](https://github.com/bridgetownrb/bridgetown/pull/52) ([jaredcwhite](https://github.com/jaredcwhite))
* Refactor `Bridgetown::Site` into multiple Concerns [#51](https://github.com/bridgetownrb/bridgetown/pull/51) ([jaredcwhite](https://github.com/jaredcwhite))
* Fix for `start.js` to eliminate junk terminal characters ([jaredcwhite](https://github.com/jaredcwhite))
* New Unified Plugins API with Builders, Source Manifests, and Autoreload [#41](https://github.com/bridgetownrb/bridgetown/pull/41) ([jaredcwhite](https://github.com/jaredcwhite))
* Add a Posts page to the new site template [#39](https://github.com/bridgetownrb/bridgetown/pull/39) ([andrewmcodes](https://github.com/andrewmcodes))
* Add `titleize` Liquid filter and improve `slugify` filter description [#38](https://github.com/bridgetownrb/bridgetown/pull/38) ([jaredcwhite](https://github.com/jaredcwhite))
* Add Bundler cache to the build GH action to improve test speed [#40](https://github.com/bridgetownrb/bridgetown/pull/40) ([andrewmcodes](https://github.com/andrewmcodes))
* Bump minimum Node requirement to 10.13 ([jaredcwhite](https://github.com/jaredcwhite))

# 0.13.0 "Klickitat" / 2020-05-05

* Configurable setting to allow executable Ruby code in Front Matter [#9](https://github.com/bridgetownrb/bridgetown/pull/9)
* Honor the configured site encoding when loading Liquid components [#33](https://github.com/bridgetownrb/bridgetown/pull/33)
* Allow configuration file as well as site metadata file to pull YAML options out of an environment specific block [#34](https://github.com/bridgetownrb/bridgetown/pull/34)
* Add Faraday to the default set of gems that get installed with Bridgetown [#30](https://github.com/bridgetownrb/bridgetown/pull/30)
* Add blank favicon.ico file to prevent error when generating a new site for the first time [#32](https://github.com/bridgetownrb/bridgetown/pull/32) ([jaredmoody](https://github.com/jaredmoody))

# 0.12.1 / 2020-05-01

* Update the minimum Ruby version requirement to 2.5

# 0.12.0 "Lovejoy" / 2020-04-27

* Add Concurrently and Browsersync for live reload, plus add new Yarn scripts [#21](https://github.com/bridgetownrb/bridgetown/pull/21)
* Add some color to terminal output
* Add code name for minor SemVer version updates

# 0.11.2 / 2020-04-24

* Add components source folder to sass-loader include paths
* Include missing commit from PR #14

# 0.11.1 / 2020-04-24

* Add a git init step to `bridgetown new` command [#18](https://github.com/bridgetownrb/bridgetown/pull/18)
* Update sass-loader webpack config to support .sass [#14](https://github.com/bridgetownrb/bridgetown/pull/14) ([jaredmoody](https://github.com/jaredmoody)) 
* Add customizable permalinks to Prototype Pages (aka `/path/to/:term/and/beyond`). Use hooks and in-memory caching to speed up Pagination. _Inspired by [use cases like this](https://annualbeta.com/blog/dynamic-social-sharing-images-with-eleventy/)…_ [#12](https://github.com/bridgetownrb/bridgetown/pull/12)

# 0.11.0 / 2020-04-21

**Prototype Pages**

You can now create a page, say `categories/category.html`, and add a `prototype` config
to the Front Matter:

```yaml
layout: default
title: Posts in category :prototype-term
prototype:
  term: category
```

And then all the site's different categories will have archives pages at this location
(e.g. `categories/awesome-movies`, `categories/my-cool-vacation`, etc.) It enables
pagination automatically, so you'd just use `paginator.documents` to loop through the
posts. [See the docs here.](https://www.bridgetown.com/docs/prototype-pages)

[#11](https://github.com/bridgetownrb/bridgetown/pull/11)

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
