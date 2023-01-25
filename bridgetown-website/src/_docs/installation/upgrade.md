---
title: Upgrading from a Previous Version
top_section: Setup
category: installation-guides
back_to: installation
order: 0
---

## Upgrading to Bridgetown 1.2

Bridgetown 1.2 brings with it a whole new initialization system along with a Ruby-based configuration format. Your `bridgetown.config.yml` file will continue to work, but over time you will likely want to migrate a good portion of your configuration over to the new format (and maybe even delete the YAML file).

To upgrade a 1.0 or 1.1 site to 1.2, edit your `Gemfile` update the version numbers in the argument for the `bridgetown` and `bridgetown-routes` (if applicable) gem and then run `bundle`. We also recommend you add `gem "rack", "~> 2.2"` as while Bridgetown/Roda supports Rack 3, other ecosystem gems such as our Active Record pluging don't yet support it.

When you upgrade to v1.2, your site will run in a legacy mode that automatically requires all gems in your Gemfile within the `bridgetown_plugins` group as before. This legacy mode is only triggered by the _absence_ of the new `config/initializers.rb` file. To opt-into the new format, create a `config/initializers.rb` file like so:

```ruby
Bridgetown.configure do |config|
  # add configuration here
end
```

Then you won't need to use the `bridgetown_plugins` Gemfile group any longer.

{%@ Note type: :warning do %}
  Do not attempt to upgrade other Bridgetown plugins along with upgrading to v1.2 unless you intend to adopt the new configuration format. The latest version of many Bridgetown plugins expect the initializers file to be in use.

  Also be advised: if you are using the dynamic routes plugin, you _must_ upgrade to the new configuration format. Read more below.
{% end %}

Once you're using the new configuration format, if you need to use a Bridgetown plugin that's not yet updated to work with v1.2, you can manually add a require statement to your configuration:

```ruby
Bridgetown.configure do |config|
  require "my-older-plugin"
  require "some-other-plugin"
end
```

Otherwise, you'll be able to add `init` statements to load in plugins. For example: `init :"bridgetown-lit-renderer"`.

If you've been using the Bridgetown SSR and Routes plugins in your Roda server, you can remove the `plugin` statements in your `server/roda_app.rb` and instead use the new initializers:

```ruby
Bridgetown.configure do |config|
  init :ssr
  init :"bridgetown-routes"
end
```

Other Roda server configuration can be placed within the file as well:

```ruby
only :server do
  roda do |app|
    app.plugin :default_headers,
      'Content-Type'=>'text/html',
      'Strict-Transport-Security'=>'max-age=16070400;',
      'X-Content-Type-Options'=>'nosniff',
      'X-Frame-Options'=>'deny',
      'X-XSS-Protection'=>'1; mode=block'
  end
end
```

If you've installed the [dotenv](https://github.com/bkeepers/dotenv) gem previously to manage environment variables, Bridgetown now has builtin support for the gem. You're free to remove past code which loaded in dotenv and use the new initializer:

```ruby
init :dotenv
```

[Read the Initializers documentation](/docs/configuration/initializers) for further details.

For plugin authors, the scoping options for `helper` and `filter` in the Builder Plugin DSL have been deprecated. You're encouraged to write simpler `helper` or `filter` code that calls the `helpers` or the `filters` variables directly to obtain access to the view-specific context. See the [Helpers](/docs/plugins/helpers) and [Filters](/docs/plugins/filters) plugin documentation for more details.

The Builder DSL also offers new `define_resource_method` ([docs here](/docs/plugins/resource-extensions)) and `permalink_placeholder` ([docs here](/docs/plugins/placeholders)) methods which you can use in lieu of older solutions.

## Upgrading to Bridgetown 1.1

To upgrade your existing 0.2x  Bridgetown site to 1.1, you’ll need to specify the new version in your Gemfile:

```ruby
gem "bridgetown", "1.1.0"
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
