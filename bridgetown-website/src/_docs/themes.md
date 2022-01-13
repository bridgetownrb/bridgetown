---
title: Themes
order: 220
top_section: Configuration
category: themes
---

Themes are [plugins](/docs/plugins) you can add to your Bridgetown website
which may provide layouts, content, components, and frontend assets, as
well as perform other tasks to enhance the functionality of your site.

You install a theme the same way you'd install any plugin, either by running
a command such as:

```sh
bundle add really-cool-theme -g bridgetown_plugins
```

Or by applying an [automation](/docs/automations):

```sh
bin/bridgetown apply https://github.com/super-great-themes/theme-one
```

The theme creator will typically provide some simple instructions on how to use
the provided theme files and enhancements. Perhaps you'll use some stylesheets
or JavaScript modules provided by the theme. Perhaps the theme will include
components such as navbars or slideshows or ways to display new content types
you can add to your site templates. Or perhaps the theme will come with layouts
you can assign to your content such as posts or collection documents.

Sometimes you might want to copy files out of a theme and into your site
repo directly. The [`bridgetown plugins cd` command](/docs/commands/plugins#copying-files-out-of-plugin-source-folders)
will help you do just that.

{%@ Note do %}
Looking for a theme to install on your site?
[Check out our plugins directory](/plugins/) for a growing collection of themes
and other useful plugins!
{% end %}

## Creating a Theme

To design a theme to distribute to others, simply [create a standard gem-based plugin](/docs/plugins#creating-a-gem) using the `bridgetown plugins new NAME` command. Follow that link for more on live testing strategies and how to release and publish your theme.

You'll need to use a [Source Manifest](/docs/plugins/source-manifests/) to
instruct the Bridgetown build process where to find your theme files.

To provide frontend assets via esbuild or Webpack, [follow these instructions](/docs/plugins/gems-and-frontend).

To aid your users in installing your plugin and setting up configuration
options and so forth, add a `bridgetown.automation.rb` [automation script](/docs/automations)
to your theme repo.

As always, if you have any questions or need support in creating your theme,
[check out our community resources](/community).