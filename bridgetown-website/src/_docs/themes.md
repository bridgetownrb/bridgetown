---
title: Themes
order: 7.5
next_page_order: 8
top_section: Structure
category: themes
---

Themes are [plugins](/docs/plugins) you can add to your Bridgetown website
which may provide layouts, content, Liquid components, and frontend assets, as
well as perform other tasks to enhance the functionality of your site.

You install a theme the same way you'd install any plugin, either by running
a command such as:

```sh
bundle add really-cool-theme -g bridgetown_plugins
```

Or by applying an [automation](/docs/automations):

```sh
bundle exec bridgetown apply https://github.com/super-great-themes/theme-one
```

The theme creator will typically provide some simple instructions on how to use
the provided theme files and enhancements. Perhaps you'll use some stylesheets
or Javascript modules provided by the theme. Perhaps the theme will include
components such as navbars or slideshows or ways to display new content types
you can add to your site templates. Or perhaps the theme will come with layouts
you can assign to your content such as posts or collection documents.

{% rendercontent "docs/note" %}
Looking for a theme to install on your site?
[Check out our plugins directory](/plugins/) for a growing collection of themes
and other useful plugins!
{% endrendercontent %}

## Creating a Theme

To create a theme to distribute to others, simply create a standard
[gem-based plugin](/docs/plugins) using the `bridgetown plugins new NAME`
command.

Use [Source Manifests](/docs/plugins/source-manifests/) to instruct
the Bridgetown build process where to find your theme files.

To provide frontend assets via Webpack, [follow these instructions](/docs/plugins/gems-and-webpack/).

To aid your users in installing your plugin and setting up configuration
options and so forth, add a `bridgetown.automation.rb` [automation script](/docs/automations)
to your theme repo.

Finally, publish your theme to the [RubyGems.org](https://rubygems.org)
and [NPM](https://www.npmjs.com) registries. There are instructions in
the sample README that is present in your new plugin folder under the heading
**Releasing**.

As always, if you have any questions or need support in creating your theme,
[check out our community resources](/docs/community).