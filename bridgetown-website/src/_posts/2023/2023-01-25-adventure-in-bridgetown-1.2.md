---
title: Adventure on the Bonny Slope with Bridgetown 1.2
subtitle: New plugin configuration format, slotted content, easier access to data, and more in this first big release of 2023.
author: jared
category: release
template_engine: none
---

Happy January 2023 folks! I'm very pleased to announce the release of Bridgetown 1.2. 🎉 [Installation](/docs) and [upgrade](/docs/installation/upgrade) instructions are available, as well as [detailed release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v1.2.0). (Why the codename Bonny Slope? [The answer may surprise you!](https://cedarmillnews.com/legacy/archive/706/bonny_slope_bootleggers.html) 👀)

Some exciting stats:

* We've reached a new record with a total of **26 contributors** to the v1.2 release, many of them new to the project!
* Among the many contributions is the addition of a new "dark mode" courtesy of Neil van Beinum and Adrian Valenzuela! Finally our site doesn't have to blind you anymore when the sun goes down. 😎
* There have been over 110,000 downloads of [Bridgetown on RubyGems](https://rubygems.org/gems/bridgetown) to date.
* Nearly [600 projects on GitHub](https://github.com/bridgetownrb/bridgetown/network/dependents) include Bridgetown as a dependency.

And ICYMI, we hosted our first-ever online conference **BridgetownConf** in November 2022, and [all the videos are available here](https://bridgetownconf.rocks) for free! Lots of great information about what's new in Bridgetown 1.2 and what's next for the ecosystem.

To recap what's included in the Bridgetown 1.2 release: 👇

* We’ve introduced a brand new **Ruby-based configuration format** that lets you require gems, load plugins, set configuration options, and customize your Roda application—all at the same time with everything in one place. Say hello to `config/initializers.rb`. [Read the docs](/docs/configuration/initializers). 
* We've simplified front matter data access to save you on keystrokes. So instead of `resource.data.title` in a page template, you can just write `data.title`. We also have a new data merge feature so you could write `data.authors[data.author]` and have `data.authors` pull from site-wide data. [Read the docs](/docs/datafiles#merging-site-data-into-resource-data).
* The new content slots features provides a new way to manage how your content flows through templates and layouts. Slots are also a fantastic addition to Bridgetown’s Ruby components. [Read the docs](/docs/template-engines/erb-and-beyond#slotted-content).
* Many quality-of-life improvements around i18n, helpers, SSR, and more.

For additional details, [read our initial beta introduction post](/release/1.2-bonny-scope-next-level/) and the [release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v1.2.0).

As always, if you run into any issues trying out Bridgetown [please hop into our community channels](/community) and let us know how we can help! And if you’re new to Ruby, we’re also pleased to recommend other resources and communities which can give you a leg up in learning this delightful and productive language.