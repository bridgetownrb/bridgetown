---
title: Upgrading from a Previous Version
top_section: Setup
category: installation-guides
back_to: installation
order: 0
---

Ready to try bringing your project up to the latest version? Here are some notes to help you get going. BTW, if you have a really old site, you may want to try incrementally upgrading versions rather than, say, go from 1.0 to 2.0 in one session.

We’ve have a [Technical Help board](https://community.bridgetown.pub/c/technicalhelp) on our **Community** site, so if you get totally suck, folks can give you a leg up! (Access to the problematic repo in question is almost always a given in order to troubleshoot, so if your code needs to remain private, please create a failing example we can access on GitHub.) There's also an **upgrade-help** channel in our [Discord chat](https://discord.gg/4E6hktQGz4) (though it's harder to include code examples and links there).

{{ toc }}

## Upgrading to Bridgetown 2.0 (Beta)

The first thing to know is that there are new minimum versions of both Ruby and Node for the v2 release cycle. In general, we try to support the previous two significant releases of these runtimes in addition to the current ones (aka Ruby 3.3 and Node 22) with each major version increase. So you will need to use a minimum of:

* Ruby 3.1.4 (⚠️ there's a bug in earlier versions of Ruby 3.1 which will prevent Bridgetown to run)
* Node 20.6 (⚠️ earlier versions of Node aren't compatible with esbuild's ESM-based config)

Sometimes that's as simple as changing your version dotfiles (for example `.ruby-version` and `.nvmrc`). We do recommend switching to the latest versions (Ruby 3.3 and Node 22 as of the time of this writing) if possible.

To upgrade to Bridgetown 2.0, edit your `Gemfile` to update the version numbers in the argument for the `bridgetown` and `bridgetown-routes` (if applicable) gem to `2.0.0.beta2` and then run `bundle update bridgetown`.

We also recommend you run `bin/bridgetown esbuild update` so you get the latest default esbuild configuration Bridgetown provides, and you may need to update your `esbuild` version in `package.json` as well.

{%@ Note type: :warning do %}

Only update your esbuild configuration if you're also willing to switch to ESM (rather than CommonJS), aka your `package.json` file will also include `"type": "module"` and you will be using `import` and `export` statements rather than `require` and `module.exports` going forward.

{% end %}

### Switching from Yarn to NPM 📦

Bridgetown uses NPM now by default, rather than Yarn, for frontend package managing. You may continue to use Yarn on your existing projects, but if you'd like to switch to NPM, you can simply delete your `yarn.lock` file, run `npm install` (shorthand: `npm i`), and check in `package-lock.json` instead. You can also use [pnpm](https://pnpm.io) if you prefer. Bridgetown is now compatible with all three package managers.

### Specifying Liquid (if necessary) 💧

The default template engine for new Bridgetown sites is ERB, with Liquid being optional. If you're upgrading a site that expects Liquid to be the default template engine, you will need to add  `template_engine :liquid` to your `config/initializers.rb` file (or `template_engine: liquid` to `bridgetown.config.yml`). If you don't even have a `config/initializers.rb` file in your project yet, see the below section under **Upgrading to Bridgetown 1.2**.

### Fixing `webpack_path` bug 🪲

Bridgetown unfortunately used to ship with templates which referrenced `webpack_path` in Liquid or Ruby-based templates, even when using esbuild. That helper is no longer available in Bridgetown 2.0, as we've removed support for Webpack entirely.

You will need to do a search & replace for all uses of `webpack_path` and change them to `asset_path`. This is a one-time fix, and then you'll be good to go for the future or even if you still need to run code on an earlier version of Bridgetown.

### Crashing Related to Roda 💥

If you encounter a weird crash which contains `uninitialized constant Bridgetown::Rack::Roda` in the error log, you will need to update the syntax of your `server/roda_app.rb` file so that it's a direct subclass of `Roda` and configures the `bridgetown_server` plugin. Here's a basic version of that file:

```rb
class RodaApp < Roda
  plugin :bridgetown_server

  # Some Roda configuration is handled in the `config/initializers.rb` file.
  # But you can also add additional Roda configuration here if needed.

  route do |r|
    # Load Roda routes in server/routes (and src/_routes via `bridgetown-routes`)
    r.bridgetown
  end
end
```

### Supporting Active Support Support 😏

Bridgetown v2 has removed a number of dependencies in the codebase on the Active Support gem (provided by the Rails framework). If that ends up causing problems with your codebase, you may need to require Active Support manually (and even Action View) in your `config/initializers.rb` file. [Here's a thread on GitHub](https://github.com/bridgetownrb/bridgetown/pull/881#issuecomment-2228693932) referencing this situation.

### Caveats with Fast Refresh in Development ⏩

Bridgetown v2 comes with a "fast refresh" feature by default. This rebuilds only files needed to display updated content in source files, rather than the entire website from scratch. However, certain features aren't yet compatible with fast refresh—most notabily, **i18n**. If you're using multiple locales in your project, you will likely want to disable fast refresh so you don't end up with broken pages/links by setting `fast_refresh false` in `config/initializers.rb`.

### Quick Search and Other Plugins 🔍

You will need to update to the latest v3 of the [Quick Search plugin](https://github.com/bridgetownrb/bridgetown-quick-search) if you use that on your site. You may also want to double-check other Bridgetown plugins you use and make sure you're on the latest version.

----

## Upgrading to Bridgetown 1.2

Bridgetown 1.2 brings with it a whole new initialization system along with a Ruby-based configuration format. Your `bridgetown.config.yml` file will continue to work, but over time you will likely want to migrate a good portion of your configuration over to the new format (and maybe even delete the YAML file).

To upgrade a 1.0 or 1.1 site to 1.2, edit your `Gemfile` update the version numbers in the argument for the `bridgetown` and `bridgetown-routes` (if applicable) gem and then run `bundle`.

We also recommend you run `bin/bridgetown esbuild update` so you get the latest default esbuild configuration Bridgetown provides.

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

