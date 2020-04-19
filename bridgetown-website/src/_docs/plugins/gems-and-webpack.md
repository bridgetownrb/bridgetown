---
title: Gem-based Plugins and Webpack
hide_in_toc: true
order: 0
category: plugins
---

{% render "docs/help_needed", page: page %}

When authoring a plugin for Bridgetown, you may find yourself wanting to ensure users
of your plugin are able to load in your frontend assets through Webpack (such as
Javascript, CSS, etc.) The best way to do this is to set up a `package.json`
manifest and [publish your frontend code as a package to the NPM registry](https://docs.npmjs.com/creating-node-js-modules#create-the-file-that-will-be-loaded-when-your-module-is-required-by-another-application).

Let's assume you've been building an awesome plugin called, unsurprisingly,
`MyAwesomePlugin`. In your `my-awesome-plugin.gemspec` file, all you need to do is
add the `yarn-add` metadata matching the NPM package name and keeping the version
the same as the Gem version:

```ruby
  spec.metadata = { "yarn-add" => "my-awesome-plugin@#{MyAwesomePlugin::VERSION}" }
```

With that bit of metadata, Bridgetown will know always to look for that package in
the users' `package.json` file when they load Bridgetown, and it will trigger a
`yarn add` command if the package and exact version number isn't present.

{% rendercontent "docs/note", title: "Make sure you update package.json!", type: "warning" %}
If you bump up your Ruby version number and forget to bump the NPM package version
at the same time, the packages will get out of sync! So remember always to update
`version.rb` and `package.json` so they have the same version number.
{% endrendercontent %}

You will need to instruct your users how to add the plugin's frontend code to their
Webpack entry points. For example, they might need to update `frontend/javascript/index.js` with:

```js
import MyAwesomePlugin from "my-awesome-plugin"

const awesomeness = new MyAwesomePlugin()
awesomeness.doCoolStuff()
```
