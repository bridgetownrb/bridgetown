---
title: Upgrading from v0.2x
top_section: Setup
category: installation-guides
back_to: installation
order: 0
---

To upgrade your existing Bridgetown site to 1.0, you’ll need to specify the new version in your Gemfile:

```ruby
gem "bridgetown", "~> {{ Bridgetown::VERSION }}"
```

You’ll also need to add Puma to your Gemfile:

```ruby
gem "puma", "~> 5.6"
```

Then run `bundle update`. (You’ll also ensure you're specifying the latest version of any extra plugins you may have added, such as the feed and seo plugins.)

Next you should run `bundle binstubs bridgetown-core` so you have access to `bin/bridgetown`, as this is now the canonical way of accessing the Bridgetown CLI within your project.

You will need to add a few additional files to your project, so we suggest using `bridgetown new` to create a separate project, then copy these files over:

* `config.ru`
* `Rakefile`
* `config/puma.rb`
* `server/*`

Also be sure to run `bin/bridgetown webpack update` so you get the latest default Webpack configuration Bridgetown provides.

Finally, you can remove `start.js` and `sync.js` and well as any scripts in `package.json` besides `webpack-build` and `webpack-dev` (and you can also remove the `browser-sync` and `concurrently` dev dependencies in `package.json`).

Going forward, if you need to customize any aspect of Bridgetown’s build scripts or add your own, you can alter your `Rakefile` and utilize Bridgetown’s automatic Rake task support.

{%@ Note type: :warning do %}
  Your plugins folder will now be loaded via Zeitwerk by default. This means you'll need to namespace your Ruby files using certain conventions or reconfigure the loader settings. [Read the documentation here](/docs/plugins#zeitwerk-and-autoloading).
{% end %}

The other major change you’ll need to work on in your project is switching your plugins/templates to use resources. There’s a fair degree of [documentation regarding resources here](/docs/resources). In addition, if you used the Document Builder API in the past, you’ll need to upgrade to the [Resource Builder API](/docs/plugins/external-apis).

{%@ Note do %}
#### Get That Live Reloading Going Again

The live reloading mechanism in v1.0 is no longer injected automatically into your HTML layout, so you'll need to add `{%% live_reload_dev_js %}` (Liquid) or `<%= live_reload_dev_js %>` (ERB) to your HTML head in order to get live reload working. Please make sure you've added `BRIDGETOWN_ENV=production` as an environment variable to your production deployment configuration so live reload requests won't be triggered on your public website. 
{% end %}

We’ve added an **upgrade-help** channel in our [Discord chat](https://discord.gg/4E6hktQGz4) so if you get totally suck, the community can give you a leg up! (Access to the problematic repo in question is almost always a given in order to troubleshoot, so if your code needs to remain private, please create a failing example we can access on GitHub.)
