---
order: 200
title: Customize Your Site
top_section: Configuration
category: configuration
---

There are three ways you can configure your Bridgetown site and customize aspects of its build process or server infrastructure.

1. Using command line options (via the CLI)
2. Using the `bridgetown.config.yml` YAML config file
3. Using the [`config/initializers.rb`](/docs/configuration/initializers) file, which is the most expressive way and provides deterministic support for loading in gem-based plugins.

**CLI:** When you use a command line option, it looks something like this:

```sh
bin/bridgetown build --future
```

This tells the build process to include posts and other resources which are future-dated.

You can read Bridgetown's [command line usage documentation here](/docs/command-line-usage).

**YAML:** When you use the `bridgetown.config.yml` file, it looks something like this:

```yaml
url: "https://www.bridgetownrb.com"
permalink: simple
timezone: America/Los_Angeles
template_engine: serbea

collections:
  docs:
    output: true
    permalink: "/:collection/:path.*"
    sort_by: order
    name: Documentation

pagination:
  enabled: true

# Environment-specific settings
development:
  unpublished: true
```

You can learn more about the various configuration options in the links below.

**Initializers:** When you use the `config/initializers.rb` file, it looks something like this:

```ruby
Bridgetown.configure do |config|
  init :dotenv

  config.autoload_paths << "jobs"

  permalink "pretty"
  timezone "America/Los_Angeles"

  only :server do
    init :mail, password: ENV["SENDGRID_API_KEY"]
  end
end
```

The initializer-style config is the most powerful, because you can configure different options for different contexts (static, server, console, rake), as well as interact with environment variables and other system features via full Ruby code. You can also initialize gem-based plugins and configure them in a single pass. And you can write your own initializers which may be called from the main `configure` block.

## Take a Deep Dive

* [Initializers](/docs/configuration/initializers)
* [Configuration Options](/docs/configuration/options)
* [Environments](/docs/configuration/environments)
* [Markdown Options](/docs/configuration/markdown)
* [Liquid Options](/docs/configuration/liquid)
* [Puma Configuration](/docs/configuration/puma)

Beyond configuration, the way you'll enhance and extend your site is through writing your own [custom plugins](/docs/plugins). Continue reading for information on how to get started writing your first plugin or installing third-party plugins.