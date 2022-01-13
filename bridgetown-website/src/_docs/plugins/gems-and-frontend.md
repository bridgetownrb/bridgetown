---
title: Gem-based Plugins and the Frontend
order: 0
top_section: Configuration
category: plugins
---

When authoring a [plugin](/docs/plugins#creating-a-gem){:data-no-swup="true"}
or [theme](/docs/themes) for Bridgetown, you may find
yourself wanting to ensure users of your plugin are able to load in your
frontend assets through esbuild or Webpack (such as JavaScript, CSS, etc.) The best way to
do this is to set up a `package.json` manifest and [publish your frontend code as a package to the NPM registry](https://docs.npmjs.com/creating-node-js-modules#create-the-file-that-will-be-loaded-when-your-module-is-required-by-another-application).

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

The [SamplePlugin demo repo](https://github.com/bridgetownrb/bridgetown-sample-plugin)
includes a `script/release` command you can use to run the test suite, release a
new version of the gem, and release a new version of the NPM package all in one
go. (This will also be present if you set up your plugin using the `bridgetown plugins new` command.)

{%@ Note type: :warning do %}
  #### Make sure you update package.json!

  If you bump up your Ruby version number and forget to bump the NPM package version at the same time, the packages will get out of sync! So remember always to update `version.rb` and `package.json` so they have the same version number.
{% end %}

You will need to instruct your users how to add the plugin's frontend code to their
esbuild/Webpack entry points. For example, they might need to update `frontend/javascript/index.js` with:

```js
import MyAwesomePlugin from "my-awesome-plugin"

const awesomeness = new MyAwesomePlugin()
awesomeness.doCoolStuff()
```

Consider [writing an automation](/docs/automations) to make this process
easier for users.
