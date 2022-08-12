---
title: Initializers
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

In addition to setting some basic options in your [`bridgetown.config.yml` configuration file](/docs/configuration/options), you can use your site's `config/initializers.rb` file to set options, instantiate gem-based plugins, and write initializer blocks to configure third-party gems.

Here's a sample `config/initializers.rb` file:

```ruby
Bridgetown.configure do |config|
  init :dotenv

  config.autoload_paths << "jobs"

  init :"bridgetown-routes"

  permalink "pretty"
  timezone "America/Los_Angeles"

  init :stripe, api_key: ENV["STRIPE_API_KEY"]

  only :server do
    init :parse_routes, require_gem: false

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
