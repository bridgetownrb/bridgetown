---
title: Initializers
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

In addition to setting some basic options in your [`bridgetown.config.yml` configuration file](/docs/configuration/options), you can use your site's `config/initializers.rb` file to set options, instantiate gem-based plugins, and write initializer blocks to configure third-party gems.

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
  Stripe.api_key = api_key
end
```

{%@ Note type: :warning do %}
  #### The `bridgetown_plugins` Bundler group has been deprecated

  In previous versions of Bridgetown, plugins were automatically required as long as they were added to the `bridgetown_plugins` group. We've changed that behavior in sites which feature a `config/initializers.rb` file. Now you can simply add gems to your `Gemfile` in any named or default group, and then load them in your codebase using `init`.
{% end %}

## Conventions

When calling an initializer, by default Bridgetown will try to require a gem by the same name. This is quite handy if you want to define an initializer specifically to configure a third-party gem. In the example above, we defined an initializer for `stripe`, so when calling that initializer it requires `stripe` automatically.

You can disable this behavior in one of two ways:

* You can pass `require_gem: false` to your initializer. In the example above, if you called `init :stripe, require_gem: false`, it would not require `stripe` automatically, and you would have to do so manually within your initializer.
* You can add initializer names to `Bridgetown::Configuration::REQUIRE_DENYLIST`. For example, by adding `Bridgetown::Configuration::REQUIRE_DENYLIST << :stripe` at the top of your initializers file, the `stripe` gem would not be required automatically.

Another convention is that you can put additional files in your `config` folder each containing an initializer, and then when you call an initializer in your configuration, it will automatically load the relevant file in `config` before executing.

So you could relocate the `Bridgetown.initializer :stripe` block definition in the example above to `config/stripe.rb`, and then Bridgetown would know to load that file in order to find the initializer before trying to call it in the configuration.

## Features of the Configuration DSL

::to be written::
