---
title: "Countdown to Production! Bridgetown 2.0 Beta 4 is Here"
subtitle: "Feature development is now frozen, and the only additional updates we anticipate will be major bug fixes only."
author: jared
category: release
---

The **Bridgetown progressive web framework** is racing to the 2.0 finish line. While we don't have a specific process for offering "release candidates", we consider this Beta 4 release to be essentially an RC. Feature development is now frozen, and the only additional updates we anticipate will be major bug fixes only.

[Read the release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.0.0.beta4), [review our "edge" documentation](https://edge.bridgetownrb.com), and [take a look at our 2.0 upgrade guide](https://edge.bridgetownrb.com/docs/installation/upgrade) if you're coming from Bridgetown 1.x. If you're new to the Bridgetown 2.0 release cycle, [read our Road to Bridgetown 2.0 series](https://edge.bridgetownrb.com/blog/future).

**Some of the goodies in Beta 4:**

* We continue to make progress in improving full build performance. While our **Fast Refresh** feature makes development an order of magnitude faster in most cases, we also want our complete build cycles to go more quickly.
* In previous releases, our primary goal was to ensure Bridgetown could "scale up" to large, ambitious application architectures. Now we're also looking at opportunities to "scale down". In the latest beta, we support Bridgetown running in a folder with only a `Gemfile` and some source files. That's it. No `config` folder, no `Rakefile`, no `config.ru`…you get the picture. And in a follow-up feature in Bridgetown 2.1, we'll support source folders located elsewhere on the file system as well as Markdown files with no front matter present. If that makes you think _wiki!_, well, you're exactly right. ☺️
* The first beta of Bridgetown 2.0 introduced the `RodaCallable` mixin for allowing any PORO (Plain Old Ruby Object) to respond to a Roda route. Now, we've introduced the `Viewable` mixin for allowing any Ruby view component to provide HTML rendering for a route. Daisy-chain callable & viewable objects and you essentially have the "View-Controller" part of **MVC** solved. We believe this will unlock opportunities to build ever larger and more robust web applications with Bridgetown.
* We've introduced an entirely new Bundled Configuration to add `minitest` to your projects, and the tests will be equally adept at validating the output of statically-generated content as well as server-side routes. Yes that's right: use the exact same testing infrastructure to test static and dynamic endpoints equally—complete with an elegant DSL for making requests and parsing either HTML or JSON.

We're also plugging away at new documentation around all of these features and more besides, and going forward the bulk of our efforts to get a final 2.0 release out the door will be the docs.

As always, if you run into any issues trying out Bridgetown 2.0 beta, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us on Bluesky](https://bsky.app/profile/bridgetownrb.com) as well as [in the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.