---
order: 6
title: Extend with Plugins
top_section: Configuration
category: plugins
---

Plugins allow you to extend Bridgetown's behavior to fit your needs. These guides help you with the specifics of creating plugins. We also have some recommended best practices to help structure your plugin.

{:.note}
If you'd like to maintain separation from your site source code and
share functionality across multiple projects, we suggest creating a gem for your plugin. This will also help you manage dependencies,  For tips on creating a gem take a look a the [Ruby gems guide](https://guides.rubygems.org/make-your-own-gem/) or look through the source code of an existing plugin such as _bridgetown-feed_.

## Installation

There are two methods of adding plugins to your site build.

1. In your site source folder, make a `_plugins` directory. Place your plugins here. Any file ending in *.rb inside this directory will be loaded before Bridgetown generates your site.

2. Add gem-based plugins to the `bridgetown_plugins` Bundler group in your `Gemfile`. For
   example:

   ```ruby
   group :bridgetown_plugins do
     gem "bridgetown-gist"
     gem "another-bridgetown-plugin"
   end
   ```

   Now all plugins from your Bundler group will be installed whenever you run `bundle install`.

## Plugin Types

There are six types of plugins in Bridgetown.

### Tags

[Tags](/docs/plugins/tags/) create custom Liquid tags which you can add to your content or design templates. For example:

* _bridgetown-youtube_

### Filters

[Filters](/docs/plugins/filters/) create custom Liquid filters to help transform data and content. For example:

* _bridgetown-time-ago_

### Generators

[Generators](/docs/plugins/generators/) create new content on your site in an automated fashion, perhaps via external APIs.
For example:

* _bridgetown-feed_

### Converters

[Converters](/docs/plugins/converters/) change a markup language from one format to another. For example:

* _bridgetown-textile-converter_

### Commands

[Commands](/docs/plugins/commands/) extend the `bridgetown` executable with
subcommands. For example:

* _bridgetown-compose_

### Hooks

[Hooks](/docs/plugins/hooks/) provide fine-grained control to trigger custom functionality at various points in the build process.

## Tips for Plugin Development

### Flags

There are configurable flags to be aware of when writing a plugin:

<table>
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