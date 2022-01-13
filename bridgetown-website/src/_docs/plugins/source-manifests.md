---
title: Source Manifests
order: 0
top_section: Configuration
category: plugins
---

A gem-based plugin can optionally provide a Source Manifest which instructs
Bridgetown how to load new content such as layouts, pages, static files, and
Liquid components from folders in the gem.

In the main Ruby code of your gem plugin (typically the root file of the `lib`
folder), underneath your `require` statements, all you need to do is register a new
source manifest with Bridgetown's plugin manager.

```ruby
Bridgetown::PluginManager.new_source_manifest(
  origin: SamplePlugin,
  components: File.expand_path("../components", __dir__),
  content: File.expand_path("../content", __dir__),
  layouts: File.expand_path("../layouts", __dir__)
)
```

The `origin` keyword argument is required (it should be the root module of your gem),
but all others are optional.

What this does is allow you to create top-level folders in your gem, for example `./layouts`,
and Bridgetown will load content from whichever folders you specify in your
manifest. So if you had the file `layouts/fancy.html`, a site could simply
reference that layout with `layout: fancy` front matter.

### Namespacing Your Content

It's considered a _best practice_ to **namespace** your content whenever possible.
In other words, within the one of those folders, create a subfolder with an
identifier matching your plugin. In the [`SamplePlugin` demo gem](https://github.com/bridgetownrb/bridgetown-sample-plugin),
you'll notice that there's `content/sample_plugin`, `layouts/sample_plugin`, etc.,
and files are placed within those subfolders.

Why do that? It's so that the plugin name becomes part of the path used to
reference the content from the parent website. Thus for `layouts/sample_plugin/layout.html`,
the front matter would be `layout: sample_plugin/layout`. For a page like
`content/photo-gallery/portfolio.html`, it would be accessible on the site via the
URL `/photo-gallery/portfolio`. For a Liquid Component located at `components/sample_plugin/widget.liquid`, you'd render it via {% raw %}`{% render "sample_plugin/widget" %}`{% endraw %}.

This is also useful in cases where the parent site needs to override some content
or a layout or whatever in order to make customizations. All the developer would
need to do is use the [plugins command](/docs/commands/plugins) to access a
folder in the gem and copy a namespaced subfolder over to the site. For example:

```sh
$ bridgetown plugins cd AwesomePlugin/Layouts
$ cp -r awesome_plugin $BRIDGETOWN_SITE/src/_layouts
```

The `awesome_plugin` folder would get copied over to the site's `_layouts` source
folder, still properly namespaced, and the site developer could make further
changes from there.

### Using Source Manifests to Create Themes

Source manifest functionality, along with the ability to publish an NPM module
with [frontend assets](/docs/plugins/gems-and-frontend), plus the
power of [automations](/docs/automations) to simply the setup process means
that you can easily design and distribute themes for use by Bridgetown site
owners.

[Read more about themes here and how to create one yourself.](/docs/themes)
