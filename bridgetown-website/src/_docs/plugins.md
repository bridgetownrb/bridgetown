---
order: 6
next_page_order: 6.5
title: Extend with Plugins
top_section: Configuration
category: plugins
---

Plugins allow you to extend Bridgetown's behavior to fit your needs. You can
write plugins yourself directly in your website codebase, or install gem-based
plugins and [themes](/docs/themes) for a limitless source of new features and
capabilities.

Be sure to
[check out our growing list of official and third-party plugins](/plugins/)
for ways to jazz up your website.

Whenever you need more information about the plugins installed on your site and what they're doing, you can use the `bridgetown plugins list` command. You can also copy content out of gem-based plugins with the `bridgetown plugins cd` command. [Read the command reference for further details.](/docs/commands/plugins)

{% rendercontent "docs/note", title: "Turn Your Plugins into Gems", extra_margin: true %}
If you'd like to maintain plugin separation from your site source code,
share functionality across multiple projects, and manage dependencies,
you can create a Ruby gem for private or public distribution. This is also
how you'd create a [Bridgetown theme](/docs/themes).

[Read further instructions below on how to create and publish a gem.](#creating-a-gem){:data-no-swup="true"}
{% endrendercontent %}

{% toc %}

## Setup

There are three methods of adding plugins to your site build.

1. In your site's root folder (aka where your config file lives), make a `plugins` folder. Write your custom plugins and save them here. Any file ending in `.rb` inside this folder will be loaded automatically before Bridgetown generates your site.

2. Add gem-based plugins to the `bridgetown_plugins` Bundler group in your `Gemfile` by running a command such as:
  ```sh
bundle add bridgetown-feed -g bridgetown_plugins
  ```

3. Running an [automation](/docs/automations) which will install one or more
plugins along with other set up and configuration:
  ```sh
bin/bridgetown apply https://github.com/bridgetownrb/bridgetown-cloudinary
  ```
   
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
class BuilderWithConfiguration < SiteBuilder
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

[Read further instructions below on how to create and publish a gem.](#creating-a-gem){:data-no-swup="true"}

## Internal Ruby API

When writing a plugin for Bridgetown, you may sometimes be interacting with
the internal Ruby API. Objects like `Bridgetown::Site`, `Bridgetown::Resource::Base`, `Bridgetown::GeneratedPage`, etc. Other times you may be interacting with Liquid Drops, which are "safe" representations of the internal Ruby API for use in Liquid templates.

Documentation on the internal Ruby API for Bridgetown is forthcoming, but meanwhile, the simplest way to debug the code you write is to run `bridgetown console` and interact with the API there. Then you can copy working code into your plugin.

## Plugin Categories

There are several categories of functionality you can add to your Bridgetown plugin:

### [Tags](/docs/plugins/tags)

Create custom Liquid tags or "shortcodes" which you can add to your content or design templates. 

### [Filters](/docs/plugins/filters)

Create custom Liquid filters to help transform data and content.

### [Helpers](/docs/plugins/helpers)

For Tilt-based templates such as [ERB, Slim, etc.](/docs/erb-and-beyond), you can provide custom helpers which can be called from your templates.

### [HTTP Requests and the Resource Builder](/docs/plugins/external-apis)

Easily pull data in from external APIs, and use a special DSL (Domain-Specific Language) to build resources out of that data.

### [Hooks](/docs/plugins/hooks)

Hooks provide fine-grained control to trigger custom functionality at various points in the build process.

### [Generators](/docs/plugins/generators)

Generators allow you to automate the creating or updating of content in your site using Bridgetown's internal Ruby API.

### [Commands](/docs/plugins/commands)

Commands extend the `bridgetown` executable using the Thor CLI toolkit.

### [Converters](/docs/plugins/converters)

Converters change a markup language from one format to another.

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

## Creating a Gem

The `bridgetown plugins new NAME` command will create an entire gem scaffold
for you to customize and publish to the [RubyGems.org](https://rubygems.org)
and [NPM](https://www.npmjs.com) registries. This is a great way to provide
[themes](/docs/themes), builders, and other sorts of add-on functionality to
Bridgetown websites. You'll want to make sure you update the `gemspec`,
`package.json`, `README.md`, and `CHANGELOG.md` files as you work on your
plugin to ensure all the necessary metadata and user documentation is present
and accounted for.

Make sure you [follow these instructions](/docs/plugins/gems-and-webpack/) to
integrate your plugin's frontend code with the users' Webpack setup. Also read
up on [Source Manifests](/docs/plugins/source-manifests/) if you have layouts,
components, pages, static files, and other content you would like your gem to
provide.

You can also provide an automation via your gem's GitHub repository by adding
`bridgetown.automation.rb` to the root of your repo. This is a great way to
provide advanced and interactive setup for your plugin. [More information on
automations here.](/docs/automations)

When you're ready, publish your plugin to the [RubyGems.org](https://rubygems.org)
and [NPM](https://www.npmjs.com) registries. There are instructions on how to
do so in the sample README that is present in your new plugin folder under the
heading **Releasing**. Of course you will also need to make sure you've uploaded
your plugin to [GitHub](https://github.com) so it can be included in our
[Plugin Directory](/plugins/) and discovered by Bridgetown site owners far and
wide. Plus it's a great way to solicit feedback and improvements in the form
of open source code collaboration and discussion.

As always, if you have any questions or need support in creating your gem,
[check out our community resources](/docs/community).

{% rendercontent "docs/note", title: "Testing Your Plugin" %}
As you author your plugin, you'll need a way to _use_ the plugin within a live
Bridgetown site. The easiest way to do that is to use a relative local path in
the test site's `Gemfile`.

```ruby
gem "my-plugin", :path => "../my-plugin", :group => :bridgetown_plugins
```

You would do something similar in your test site's `package.json` as well (be sure to run [yarn link](https://classic.yarnpkg.com/en/docs/cli/link) so Yarn knows not to install your local path into `node_modules`):

```json
"dependencies": {
  "random-js-package": "2.4.6",
  "my-plugin": "../my-plugin"
}
```

You may need to restart your server at times to pick up changes you make
to your gem (unfortunately hot-reload doesn't always work with gem-based plugins).

Finally, you should try writing some [RSpec tests](https://relishapp.com/rspec)
in the `spec` folder of your gem. These tests could ensure your tags, filters,
and other content are working as expected and won't break in the future as code
gets updated.
{% endrendercontent %}

## Cache API

Bridgetown includes a [Caching API](/docs/plugins/cache-api/) which is used both internally as well as exposed for plugins. It can be used to cache the output of deterministic functions to speed up site generation.