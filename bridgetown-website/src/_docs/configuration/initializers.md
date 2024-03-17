---
title: Initializers
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

In addition to setting some basic options in your [`bridgetown.config.yml` configuration file](/docs/configuration/options), you can use your site's `config/initializers.rb` file to set options, instantiate gem-based plugins, and write initializer blocks to configure third-party gems.

{%@ Note type: :warning do %}
  #### Heads up: the `bridgetown_plugins` Bundler group has been deprecated

  In previous versions of Bridgetown, plugins were automatically required as long as they were added to the `bridgetown_plugins` group. We've changed that behavior in sites which feature a `config/initializers.rb` file. Now you can simply add gems to your `Gemfile` in any named or default group, and then load them into your codebase using `init`.
{% end %}

Here's a sample `config/initializers.rb` file showcasing many features of the configuration <abbr title="Domain-Specific Language">DSL</abbr>:

```ruby
Bridgetown.configure do |config|
  init :dotenv

  config.autoload_paths << "jobs"

  init :ssr do
    setup -> site do
      # perform site setup tasks only in the server context
    end
  end
  init :"bridgetown-routes"

  # you can configure site settings here just like you would in bridgetown.config.yml
  permalink "pretty"
  timezone "America/Los_Angeles"

  # some initializers accept additional options
  init :stripe, api_key: ENV["STRIPE_API_KEY"]

  only :server do
    # code which runs only in server context

    init :parse_routes

    # you can also provide initializer options in block DSL form:
    init :mail do
      password ENV["SENDGRID_API_KEY"]
    end
  end

  only :static, :console do
    # code which runs only in static and console contexts
  end

  only :rake do
    # code which runs only in the Rake context
  end

  except :static, :console do
    # you can define hooks witin your initializers file:
    hook :site, :after_init do |site|
      # runs after a site is initialized in server, Rake, etc. contexts, but not static or console
    end
  end
end

Bridgetown.initializer :stripe do |api_key:|
  Bridgetown.logger.info "Stripe:", "Setting the API key"
  Stripe.api_key = api_key
end
```

{{ toc }}

## Conventions

When calling an initializer, by default Bridgetown will try to require a gem by the same name. This is quite handy if you want to define an initializer specifically to configure a third-party gem. In the example above, we defined an initializer for `stripe`, so when calling that initializer it requires `stripe` automatically.

You can disable this behavior in one of two ways:

* You can pass `require_gem: false` to your initializer. In the example above, if you called `init :stripe, require_gem: false`, it would not require `stripe` automatically, and you would have to do so manually within your initializer.
* You can add initializer names to `Bridgetown::Configuration::REQUIRE_DENYLIST`. For example, by adding `Bridgetown::Configuration::REQUIRE_DENYLIST << :stripe` at the top of your initializers file, the `stripe` gem would not be required automatically.

Another convention is that you can put additional files in your `config` folder each containing an initializer, and then when you call an initializer in your configuration, it will automatically load the relevant file in `config` before executing. More on that below.

You can disable this behavior by passing `require_initializer: false` to `init`—perhaps in a case where you already have a similarly-named file in your `config` folder which you don't want to get processed as an initializer.

## Features of the Configuration DSL

The `Bridgetown.configure` block passes you a `config` object which is also the exact object that's the scope of the configure block. This means you can set new configuration options either by calling configuration keys like methods, much like [Bridgetown's Ruby front matter](/docs/front-matter#the-power-of-ruby-in-front-matter) feature— or you can set options on the `config` object.

```rb
set_a_value "Same thing"
config.set_a_value = "Same thing"
# ^ They do the same thing!
```

Having access to the `config` object is handy if you want to manipulate existing options:

```rb
config.autoload_paths << "models"
```

Besides setting primary configuration options, you can call `init`, `only`,  `except`, `roda`, and `hook`. Continue reading for further details.

### The `init` method and initializers

As seen above, when you call `init` you can pass additional configuration options requested by the initializer in one of two ways: using a Hash, or using a configure block. Thus these two are equivalent:

```rb
init :stripe, api_key: ENV["STRIPE_API_KEY"]
```

```rb
init :stripe do
  api_key ENV["STRIPE_API_KEY"]
end
```

Inside of the block, you can use the DSL just like in the main `configure` block. You can also reference keys that were previously set:

```rb
init :some_initializer do
  value "Abc123"
  another_value "#{value}456"
end
```

These configuration values will get passed directly to the initializer. But what if the plugin requires you to set values on the main config instead (as many legacy Bridgetown plugins will)? No problem! While it's not strictly necessary, you can still use the init block and just reference the main config object from enclosing scope for a clear visual grouping:

```rb
init :legacy_plugin do
  config.legacy_plugin_setting = 123
end
```

If you're using a legacy plugin—or any third-party Ruby gem without an initializer—you'll get a message something like:

```
Initializing: The `insert_gem_name_here' initializer could not be found
```

No worries! _You can write your own initializer._ 😎

As in the example at the top of the page, you can place an initializer right alongside the configure block in `config/initializers.rb`. You can also place a file named the same as the gem or plugin directly in `config`. In the use case of using the Stripe gem, you could add to `config/stripe.rb`:

```rb
Bridgetown.initializer :stripe do |api_key:|
  Bridgetown.logger.info "Stripe:", "Setting the API key"
  Stripe.api_key = api_key
end
```

Then when you call `init :stripe, api_key: ENV["STRIPE_API_KEY"]`, code to the effect of `require "stripe"` will get called automatically and the initializer will get passed the value of `api_key`.

Some advanced features provided by initializers will be covered in a later section.

### Using `only`, `except`, and understanding initialization contexts

There are multiple initialization contexts within the Bridgetown environment. By default, using `init` or setting configuration options will apply to all possible contexts. But you can limit certain settings by using `only` and `except`. Here's a list of available contexts:

* **static**: This context is activated only for static builds (aka when running `bin/bridgetown build` or `bin/bridgetown deploy`, or during the static build process of `bin/bridgetown start`).
* **server**: This context is activated only when running the Roda web server (aka when running `bin/bridgetown start`).
* **console**: This context is activated only when running the Bridgetown console via `bin/bridgetown console`.
* **rake**: This context is activated when you run a Rake task and it either calls `run_initializers` or accesses `site`.

So for example, your configure block could include this:

```rb
only :static do
  puts "I get run only for static builds!"
end

except :static do
  puts "I get run for any context other than a static build!"
end
```

You can pass multiple contexts to  `only` or `except`:

```rb
only :static, :server do
  puts "I get run for both static builds and the server process, but not for the console or Rake tasks."
end
```

And finally, you can set configuration options that are broadly applicable, but override them in a specific context.

```rb
my_val 123

only :server do
  init :parse_routes
  my_val 456
end

puts my_val # => 123 for most contexts, 456 for the server context
```

### Adding `roda` blocks

If you wish to configure your site's [Roda server](/docs/routes/), including setting up Roda plugins, you can add a `roda` block to your configuration. This provides a convenient alternative to placing configuration in your Roda class directly.

The `app` argument of a `roda` block is the class of your Roda application (typically `RodaApp`) in a Bridgetown project.

```rb
roda do |app|
  app.plugin :default_headers,
    'Content-Type'=>'text/html',
    'Strict-Transport-Security'=>'max-age=16070400;',
    'X-Content-Type-Options'=>'nosniff',
    'X-Frame-Options'=>'deny',
    'X-XSS-Protection'=>'1; mode=block'
end
```

While it's not strictly required that you place a Roda block inside of an `only :server do` block, it's probably a good idea that you do since Roda blocks aren't used in any other configuration context.

{%@ Note do %}
  As mentioned above, you can still add and configure plugins directly in your Roda class file (`server/roda_app.rb`) just like any standard Roda application, but using a Roda configuration block alongside your other initialization steps is a handy way to keep everything consolidated. Bear in mind that the Roda blocks are all executed prior to anything defined within the class-level code of `server/roda_app.rb`, so if you write any code in a Roda block that relies on state having already been defined in the app class directly, it will fail. Best to keep Roda block code self-contained, or reliant only on other settings in the Bridgetown initializers file.
{% end %}

### SSR & Dynamic Routes

The SSR features of Bridgetown, along with its companion file-based routing features, are now configurable via initializers.

```rb
init :ssr

# optional:
init :"bridgetown-routes"

# …or you can just init the routes, which will init :ssr automatically:

init :"bridgetown-routes"
```

If you want to run some specific site setup code on first boot, or any time there's a file refresh in development, provide a `setup` block inside of the SSR initializer.

```rb
init :ssr do
  setup -> site do
    # access the site object, add data with `site.data`, whatever
  end
end
```

For the file-based routing plugin, you can provide additional configuration options to add new source paths (relative to the `src` folder, unless you specify an absolute file path) or add other routable extensions (for example to support a custom template engine):

```rb
init :"bridgetown-routes", additional_source_paths: ["some_more_routes"], additional_extensions: ["tmpl"]
```

For more on how SSR works in Bridgetown, check out our [Routes documentation here](/docs/routes).

## Low-level Boot Customization

If you need to run Ruby code at the earliest possible moment, essentially right when the `bridgetown` executable has finished its startup process, you can add a `config/boot.rb` file to your repo. This is particularly useful if you wish to extend `bridgetown` with new commands.

```ruby
# Normally the following is run automatically, so by adding config/boot.rb, you should include
# this Bundler setup:
Bundler.setup(:default, Bridgetown.env)

# Now you can require a gem which adds a command to `bridgetown` via Thor:
require "some_gem_here"

# Or require your own Ruby file:
require_relative "../ruby_code_file.rb"
```

[Read more about defining Thor-based commands here.](/docs/plugins/commands)

## Built-in Initializers

Bridgetown ships with several initializers you can add to your configuration. In future versions of Bridgetown, we expect to make our overall architecture a little more modular so you can use the initializer system to specify just those key features you need (and by omission which ones you don't!).

### Dotenv

The Dotenv gem provides a simple way to manage environment variables with your Bridgetown project. Simply add the gem to your Gemfile (`bundle add dotenv`), and then add the initializer to your configuration:

```rb
init :dotenv
```

Now anywhere in your Ruby plugins, templates, etc., you can access environment variables via `ENV` once you've defined your `.env` file. Our integration also supports specially-named files such as `.env.development`, `.env.test`, etc.

### Inflector

Zeitwerk's inflector can be configured to use ActiveSupport::Inflector. This
will become the default in v2.0.

```ruby
config.inflector = ActiveSupport::Inflector
```

To add new inflection rules, use the following format.

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "RESTful"
end
```

### Parse Roda Routes

Because of how Roda works via its dynamic routing tree, there's no straightforward way to programmatically list out all the routes in your application.

However, Roda provides a convention which lets you add code comments next to your routing blocks. These comments are then converted to a JSON file containing route information which can then be printed out with a single command.

TBC…
