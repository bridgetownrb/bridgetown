---
title: "Back to Basics: Bridgetown v0.20 “Healy Heights”"
subtitle: |
  Doing the hard work of improving Bridgetown at the core level as we head towards our one-year anniversary.
author: jared
category: release
---

Before I go grab some corned beef and cabbage to celebrate St. Patrick's Day (here in the U.S.), I want to tell you all about our latest release! Introducing [Bridgetown v0.20 "Healy Heights"](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.20.0) — for those looking to upgrade, simply edit your Gemfile:

```ruby
gem "bridgetown", "~> 0.20"
```

And then run `bundle update bridgetown`. You might want to create a new blank project and investigate what's new in `package.json` and `webpack.config.js` because we've made some significant improvements. (And in the future, we'll have a more automated upgrade tool there you can use!)

So what's new in "Healy Heights"?

### Smarter Defaults and Integration with Webpack

When we added Webpack integration from the very beginnings of Bridgetown, it was always in service to one goal: make utilizing the latest frontend packages and tools a no-brainer for your site in as straightforward a manner as possible. Part of accomplishing such a goal is to have really a solid "default" Webpack config so you mostly don't need to touch it or worry about it as you work on your project.

So we kept the config pretty simple. But over time we've heard that it was a little _too_ simple. For example, if you wanted more than one entry point (aka bundle with an output JS file you can load), or you wanted to reference bundled images and other assets directly from your HTML or CSS, that was hard to do.

In Bridgetown 0.20 we've beefed up the `webpack_path` helper/Liquid tag so that you can use it to reference any entry point or bundled asset in your Webpack manifest. We also improved the configuration defaults a bit around the handling and fingerprinting of font files and image files. [So take it out for a spin](/docs/frontend-assets) and let us know if we got it right this time!

### Better Console DX (Developer Experience)

Something that was personally driving me bonkers was whenever you opened up a console (aka REPL, aka IRB) and pressed the up-arrow key, you wouldn't get any of the commands you'd executed in the console previously. You'd get stuff from IRB run elsewhere (say, a Rails app). What the what?!

Thankfully, that's now fixed in Bridgetown 0.20! Any time you run `bridgetown console` and access your command history, you'll get the latest stuff everytime. Now only that, but any time you print out or inspect the `site` object, you'll get a concise little description rather than a giant wad of Matrix-style gobbledeegook all over your screen. DX FTW!!

### The Great Content Realignment: Introducing Resources

But the biggest news by far in "Healy Heights" is the arrival of an experimental, opt-in new content engine. Yes, my friends: the days of pages being different than blog posts being different than custom collection documents being different than files in `_data` are coming to an end! The days of blog taxonomies (categories and tags) being restricted to posts only are coming to an end! The days of scratching your head trying to figure out why permalink configuration is so confusing and sometimes mislabeled are coming to an end! The days of wondering how you'll implement robust _i18n_ are coming to an end! The days of not being able to easily implement targeted data fetching and rendering to enable all kinds of cool use cases (like a Rails API surgically serving up layout-less HTML of a specific page on the site in real-time) are coming to an end! The days of…well, I think you get the idea. 😃

![The Resource Rendering Pipeline](/images/resource-pipeline.png)
{: .my-8}

We have an entirely new system built around a singular concept we're calling the **Resource**. [As the documentation says](/docs/resources), a resource is a 1:1 mapping between a unit of content and a URL (remember the acronym Uniform **Resource** Locator?). A "unit of content" is typically a Markdown or HTML file along with YAML front matter saved somewhere in the `src` folder. While certain resources don't actually get written to URLs such as data files (and other resources and/or collections can be marked to avoid output), the concept is sound. Resources encapsulate the logic for how raw data is transformed into final content within the site rendering pipeline. (And the docs go on…)

Without getting to far into the weeds, the greatest strength of Bridgetown having been built on top of the proven foundation of Jekyll has also been our greatest weakness. We inherited all the nice parts, but we also inherited all the nasty bits. Bridgetown 0.20 is our first real foray into doing away with most of the low-level nasty bits, ensuring an advanced and forward-looking foundation for the next ten years of Bridgetown.

The transition from the legacy content engine to the new "resource" content engine will be a bit rocky. That's why we're outlining a clear road map for how to get from A to B:

* In this release, the resource content engine is **opt-in**.
* In a subsequent release (likely either 0.21 or 0.22), we will make the resource engine the **default** with the legacy engine still available but officially marked deprecated.
* For the release of Bridgetown 1.0 later this year, the legacy engine will be removed and the resource engine will reign supreme. This is the place of "API stability" we want to arrive at in order to feel secure in labeling the release a "1.0".

Much of the pain will be related to rewriting vast swaths of documentation and releasing various plugin updates, as well as providing enough assistance for the Bridgetown sites already in the wild to upgrade. We also anticipate feedback and ideas informing further changes and enhancements to the resource content engine before we hit 1.0. The time to "get this right" is now. So let's get it right.

Ultimately, our goal isn't simply to compete with Jekyll. Bridgetown sits in a competitive landscape among Jamstack giants such as Gatsby, Eleventy, Next.js, Hugo, and many others. If the Ruby ecosystem isn't able to produce a worthy contender, we might as well pack our bags now. (Thankfully, we're genuinely excited about what's coming down the pike.)

So as we look ahead to celebrating Bridgetown's one-year anniversary next month, let's appreciate how far we've come, even as we recognize how far we have to go. The journey is worth the effort.

Have any questions? Run into any issues? Got some juicy feedback? Want to tell us about your spiffy new project? Hop in the [Discord Chat or the GitHub Discussions](/docs/community) and let us know!
{:style="font-weight:bold"}
