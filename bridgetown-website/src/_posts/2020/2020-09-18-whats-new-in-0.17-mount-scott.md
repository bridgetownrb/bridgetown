---
title: "The Data Cascade, Find Tag, and More in Bridgetown 0.17"
subtitle: |
  We're pleased as Punch to announce the release of Bridgetown 0.17, codenamed "Mount Scott". Some of the improvements are optimizations at the code level and preparing for bigger features down the road (i18n), but there are also a few goodies you can start using in your projects today.
author: jared
category: release
---

TGIF! We've reached the end of a very challenging work week for those of us on the west coast of the United States. Our hearts go out to everyone who's been affected by the wildfires.

While we don't have much control over the environment, we do have control over our Rubygems account, and so we're pleased as Punch to announce [the release of Bridgetown 0.17](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.17.0), codenamed "Mount Scott". Some of the improvements are optimizations at the code level and preparing for bigger features down the road (i18n), but there are also a few goodies you can start using in your projects today.

* **The Data Cascade & Front Matter Defaults**.  Previously, the only way to set front matter defaults for pages, posts, and other documents was to use a powerful but confusing syntax within your site's configuration file. Now, all you have to do is add a `_defaults.yml` (or JSON) file to a folder in your source tree, and that data will be applied as front matter for any documents in that folder or subfolders. You can have multiple defaults files in various parts of your source tree or even at the root `src` folder to affect all documents site-wide. It's pretty handy! [More documentation here](https://www.bridgetownrb.com/docs/configuration/front-matter-defaults){:data-no-swup="true"}.
* **The Find Tag**. In any Liquid template, you can now use a single tag to find documents matching a particular set of conditions and assign the first match or all matches to a local variable. For most use cases, this will replace usage of the `where_exp` filter and make your code more readable. [More documentation here](https://www.bridgetownrb.com/docs/liquid/tags#find-tag){:data-no-swup="true"}.
* **Easily Add Helpers**. If you're using a Ruby-based template language (ERB, Slim, etc.) and you want to write your own helpers, you can now do so with a simple DSL in a Builder plugin. Create expressive new ways to transform and output content in your templates with just a few lines of code! [More documentation here](https://www.bridgetownrb.com/docs/plugins/helpers){:data-no-swup="true"}.
* **Ruby Front Matter Now On by Default**. Whereas in previous releases you had to set an environment variable before you could add Ruby code directly in your front matter, now that feature is available out-of-the-box (although you can still turn it off if you have any security concerns regarding user-submitted content). [More documentation here](https://www.bridgetownrb.com/docs/front-matter#ruby-front-matter){:data-no-swup="true"}.

So `bundle update bridgetown` and let us know how it goes! We have some very exciting features in store for the next few releases, so [make sure you follow us on Twitter](https://twitter.com/bridgetownrb) and [join our Discord chat](https://discord.gg/V56yUWR) so you won't miss a beat.

Also, if you've benefited at all in any way from Bridgetown, [please consider becoming a sponsor on GitHub](https://github.com/sponsors/jaredcwhite) so we can continue to work extensively on Bridgetown and push the Ruby and Jamstack ecosystems forward. ❤️
