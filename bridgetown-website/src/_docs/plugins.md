---
order: 6
title: Extend with Plugins
top_section: Configuration
category: plugins
---

Plugins allow you to extend Bridgetown's behavior to fit your needs. These guides help you with the specifics of creating plugins. We also have some recommended best practices to help structure your plugin.

In addition, be sure to check out [our growing list of official and third-party plugins](/plugins/)
for ways you can jazz up your Bridgetown website.

{% rendercontent "docs/note", title: "Roll It All Up in a Gem" %}
If you'd like to maintain separation from your site source code and
share functionality across multiple projects, we suggest creating a gem for your plugin. This will also help you manage dependencies.

You can [download the source code of our sample plugin project](https://github.com/bridgetownrb/bridgetown-sample-plugin)
to get started, and read the [Ruby gems guide](https://guides.rubygems.org/make-your-own-gem/)
for more details on creating and publishing your own gem.

Make sure you [follow these instructions](/docs/plugins/gems-and-webpack/) to integrate your plugin's frontend code
with the users' Webpack setup!
{% endrendercontent %}

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
   
## Internal Ruby API

When writing a plugin for Bridgetown, you will be interacting with
the internal Ruby API. Objects like `Bridgetown::Site`, `Bridgetown::Document`, `Bridgetown::Page`, etc.

Documentation on the internal Ruby API for Bridgetown is forthcoming, but meanwhile, the simplest way to debug the code you write is to run `bridgetown console` and interact with the API there. Then you can copy working code into your plugin.

## Plugin Types

There are six types of plugins in Bridgetown.

### [Tags](/docs/plugins/tags/)

Tags create custom Liquid tags which you can add to your content or design templates. For example:

* [_bridgetown-seo-tag_](https://github.com/bridgetownrb/bridgetown-seo-tag)

### [Filters](/docs/plugins/filters/)

Filters create custom Liquid filters to help transform data and content.

### [Generators](/docs/plugins/generators/)

Generators create new content on your site in an automated fashion, perhaps via external APIs.
For example:

* [_bridgetown-feed_](https://github.com/bridgetownrb/bridgetown-feed)

### [Converters](/docs/plugins/converters/)

Converters change a markup language from one format to another.

### [Commands](/docs/plugins/commands/)

Commands extend the `bridgetown` executable with subcommands.

### [Hooks](/docs/plugins/hooks/)

Hooks provide fine-grained control to trigger custom functionality at various points in the build process.

## Tips for Plugin Development

### Flags

There are configurable flags to be aware of when writing a plugin:

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Flag</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>priority</code></p>
      </td>
      <td>
        <p>
          This flag determines what order the plugin is loaded in. Valid values
          are: <code>:lowest</code>, <code>:low</code>, <code>:normal</code>,
          <code>:high</code>, and <code>:highest</code>. Highest priority
          matches are applied first, lowest priority are applied last.
        </p>
      </td>
    </tr>
  </tbody>
</table>

To use one of the example plugins above as an illustration, here is how you’d
specify these flags:

```ruby
module MySite
  class UpcaseConverter < Converter
    priority :low
    ...
  end
end
```

### Cache API

Bridgetown includes a [Caching API](/docs/plugins/cache-api/) which is used both internally as well as exposed for plugins. It can be used to cache the output of deterministic functions to speed up site generation.