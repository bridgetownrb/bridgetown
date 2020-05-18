---
order: 6
title: Extend with Plugins
top_section: Configuration
category: plugins
---

Plugins allow you to extend Bridgetown's behavior to fit your needs. These guides help you with the specifics of creating plugins. We also have some recommended best practices to help structure your plugin.

In addition, be sure to check out [our growing list of official and third-party plugins](/plugins/)
for ways you can jazz up your Bridgetown website.

Whenever you need more information about the plugins installed on your site and what they're doing, you can use the `bridgetown plugins list` command. You can also copy content out of gem-based plugins with the `bridgetown plugins cd` command. [Read the command reference for further details.](/docs//

{% rendercontent "docs/note", title: "Roll It All Up in a Gem" %}
If you'd like to maintain separation from your site source code and
share functionality across multiple projects, we suggest creating a gem for your plugin. This will also help you manage dependencies.

You can [download the source code of our sample plugin project](https://github.com/bridgetownrb/bridgetown-sample-plugin)
to get started, and read the [Ruby gems guide](https://guides.rubygems.org/make-your-own-gem/)
for more details on creating and publishing your own gem.

Make sure you [follow these instructions](/docs/plugins/gems-and-webpack/) to integrate your plugin's frontend code
with the users' Webpack setup. Also read up on [Source Manifests](/docs/plugins/source-manifests/) if you have layouts, static files, and other content you would like your gem to provide.
{% endrendercontent %}

{% toc %}

## Setup

There are two methods of adding plugins to your site build.

1. In your site's root folder (aka where your config file lives), make a `plugins` folder. Write your custom plugins and save them here. Any file ending in `.rb` inside this folder will be loaded before Bridgetown generates your site.

2. Add gem-based plugins to the `bridgetown_plugins` Bundler group in your `Gemfile`. For
   example:

   ```ruby
   group :bridgetown_plugins do
     gem "bridgetown-feed"
     gem "another-bridgetown-plugin"
   end
   ```

   Now all plugins from your Bundler group will be installed whenever you run `bundle install`.
   
## Introduction to the Builder API

**_New_** in Bridgetown 0.14 is the Builder API (also sometimes referred to as the Unified Plugins API). This is a brand-new way of writing plugins for both  custom plugins as well as gem-based plugins. Most previous techniques of writing plugins (registering Liquid tags and filters, generators, etc.) have been rebranded as the Legacy API. This API isn't going away any time soon as it provides the underlying functionality for the Builder API. However, we recommend all new plugin development center around the Builder API going forward.

### Local Custom Plugins

For local plugins, simply create a new `SiteBuilder` class in your `plugins` folder:

```ruby
# plugins/site_builder.rb
class SiteBuilder < Bridgetown::Builder
end
```

Then in `plugins/builders`, you can create one or more subclasses of `SiteBuilder` and write your plugin code within the `build` method which is called automatically by Bridgetown early on in the build process (specifically during the `pre_read` event before content has been loaded from the file system).

```ruby
# plugins/builders/add_some_tags.rb
class AddSomeTags < SiteBuilder
  def build
    liquid_tag "cool_stuff", :cool_tag
  end

  def cool_tag(attributes, tag)
    "This is so cool!"
  end
end
```

Builders provide a couple of instance methods you can use to reference important data during the build process: `site` and `config`.

So for example you could add data with a generator:

```ruby
class AddNewData < SiteBuilder
  def build
    generator do
      site.data[:new_data] = {new: "New stuff"}
    end
  end
end
```

And then reference that data in any Liquid template:

```Liquid
{% raw %}{{ site.data.new_data.new }}{% endraw %}

  output: New stuff
```

### Default Configurations

The `config` instance method is available to access the Bridgetown site configuration object, and along with that you can optionally define a default configuration that will be included in the config object—and can be overridden by config settings directly in `bridgetown.config.yml`. For example:

```ruby
def BuilderWithConfiguration < SiteBuilder
  CONFIG_DEFAULTS = {
    custom_config: {
      my_setting: 123
    }
  }

  def build
    p config[:my_setting] # 123

    # now add this to bridgetown.config.yml:
    # custom_config:
    #   my_setting: "one two three"

    p config[:my_setting] # "one two three"
  end
```

### Gem-based Plugins

For a gem-based plugin, all you have to do is subclass directly from `Bridgetown::Builder` and then use the `register` class method to register the builder with Bridgetown when the gem loads. Example:

```ruby
module Bridgetown
  module MyNiftyPlugin
    class Builder < Bridgetown::Builder
      CONFIG_DEFAULTS = {
        my_nifty_plugin: {
          this_goes_to_11: true
        }
      }

      def build
        this_goes_to = config[:my_nifty_plugin][:this_goes_to_11]
        # do other groovy things
      end
    end
  end
end

Bridgetown::MyNiftyPlugin::Builder.register
```

If you have layouts, static files, pages, and other content you would like your gem
to provide, use [Source Manifests](/docs/plugins/source-manifests/) to instruct
the build process where to find them. To provide frontend assets via Webpack,
[follow these instructions](/docs/plugins/gems-and-webpack/).

## Internal Ruby API

When writing a plugin for Bridgetown, you may sometimes be interacting with
the internal Ruby API. Objects like `Bridgetown::Site`, `Bridgetown::Document`, `Bridgetown::Page`, etc. Other times you may be interacting with Liquid Drops, which are "safe" representations of the internal Ruby API for use in Liquid templates.

Documentation on the internal Ruby API for Bridgetown is forthcoming, but meanwhile, the simplest way to debug the code you write is to run `bridgetown console` and interact with the API there. Then you can copy working code into your plugin.

## Plugin Categories

There are several categories of functionality you can add to your Bridgetown plugin:

### [Tags](/docs/plugins/tags/)

Create custom Liquid tags or "shortcodes" which you can add to your content or design templates. 

### [Filters](/docs/plugins/filters/)

Create custom Liquid filters to help transform data and content.

### [HTTP Requests and the Document Builder](/docs/plugins/external-apis/)

Easily pull data in from external APIs, and use a special DSL (Domain-Specific Language) to build documents out of that data.

### [Hooks](/docs/plugins/hooks/)

Hooks provide fine-grained control to trigger custom functionality at various points in the build process.

### [Generators](/docs/plugins/generators/)

Generators allow you to automate the creating or updating of content in your site using Bridgetown's internal Ruby API.

## Legacy API-only Plugin Development

There are two types of plugin features which are only available via the Legacy API.

### [Converters](/docs/plugins/converters/)

Converters change a markup language from one format to another.

### [Commands](/docs/plugins/commands/)

Commands extend the `bridgetown` executable with subcommands.

{:.mt-8}
#### Priority Flag

You can configure a Legacy API plugin (mainly generators and converters) with a specific `priority` flag. This flag determines what order the plugin is loaded in.

Valid values are: <code>:lowest</code>, <code>:low</code>, <code>:normal</code>,
          <code>:high</code>, and <code>:highest</code>. Highest priority
          matches are applied first, lowest priority are applied last.

Here is how you’d specify this flag:

```ruby
module MySite
  class UpcaseConverter < Converter
    priority :low
    ...
  end
end
```

## Cache API

Bridgetown includes a [Caching API](/docs/plugins/cache-api/) which is used both internally as well as exposed for plugins. It can be used to cache the output of deterministic functions to speed up site generation.