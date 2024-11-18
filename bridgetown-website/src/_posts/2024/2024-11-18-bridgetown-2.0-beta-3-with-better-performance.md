---
title: "Performance Boost with Bridgetown 2.0 Beta 3"
subtitle: "Long build times reduced, fast refresh now supporting i18n, ESM all the way, and more."
author: jared
category: release
---

The third beta of Bridgetown 2.0 is here! [Read the release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.0.0.beta3), [review our "edge" documentation](https://edge.bridgetownrb.com), and you will likely want to [take a look at our 2.0 upgrade guide](https://edge.bridgetownrb.com/docs/installation/upgrade) if you're coming from Bridgetown 1.x. If you're new to the Bridgetown 2.0 release cycle, [read our Road to Bridgetown 2.0 series](https://edge.bridgetownrb.com/blog/future).

**Some of the goodies in Beta 3:**

It's not often we're able to see a major performance gain with a single fix. Thankfully, [with this PR in place](https://github.com/bridgetownrb/bridgetown/pull/915), we've seen full build performance gains of 15-25%…possibly even higher. Huge thanks to Maxime Lapointe for the awesome detective work.

A bug resulting in Liquid templates not working as expected with the new fast refresh feature has been resolved.

Sites using multiple locales (aka i18n) are now better supported by fast refresh. If you encounter any additional issues seeing updated content after making changes to your content files, please file an issue and let us know.

You can now switch to ESModules (ESM) and away from CommonJS for your projects! Run `bin/bridgetown esbuild update` to install the latest frontend configuration. You may need to edit some of your JS files manually in order to remove outdated `require` statements and use `import` instead.

Finally, we've been doing a lot of behind-the-scenes work to improve API-level documentation as well as guide-level documentation. For example, you can read up on [our new all-Ruby syntax for HTML templates: Streamlined](https://edge.bridgetownrb.com/docs/template-engines/erb-and-beyond#streamlined).

As always, if you run into any issues trying out Bridgetown 2.0 beta, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us now on Bluesky](https://bsky.app/profile/bridgetownrb.com) as well as [in the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.