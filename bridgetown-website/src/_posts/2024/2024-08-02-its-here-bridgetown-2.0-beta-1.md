---
title: "It’s Finally Here! Bridgetown 2.0 Beta 1"
subtitle: "New baselines, better defaults, greater dev performance (Signals!), an enhanced full-stack application framework, and a whole lot more."
author: jared
category: release
---

I'm pleased to announce the first beta release of **Bridgetown 2.0**, the premier static site generator 🤝 full-stack web framework **powered by Ruby**. Many thanks to everyone who contributed! And if you're wondering _hey, where's the new code name?_ …that is forthcoming. We're going to have a little fun playing with the branding on this one, so stay tuned. 😎

In the meantime, Bridgetown 2.0 is really all about two major initiatives: removing many deprecations from the 1.x line all while tightening up internals and providing a high quality & stable API, and raising baselines with improved defaults to enable a clear vision for the next several years of Bridgetown development.

We've written about many of these initiatives previously on the blog—see these posts for reference:

* [Part 1 (Stuck in Burnout Marsh)](/future/road-to-bridgetown-2.0-escaping-burnout/)
* [Part 2 (New Baselines)](/future/road-to-bridgetown-2.0-new-baselines/)
* [Happy 4th Birthday, Bridgetown!](/news/happy-birthday-bridgetown/)
* [Part 3 (Fast Refresh)](/future/road-to-bridgetown-2.0-fast-refresh/)

What follows is a simplified list of updates as noted in our [changelog](https://github.com/bridgetownrb/bridgetown/blob/main/CHANGELOG.md). (You can also [browse a 1.3...2.0 diff](https://github.com/bridgetownrb/bridgetown/compare/1-3-stable...main) if you're _really_ curious what's going on.)

[Our "edge" documentation is available here](https://edge.bridgetownrb.com), and you will likely want to [take a look at our 2.0 upgrade guide](https://edge.bridgetownrb.com/docs/installation/upgrade) if you're an existing user of Bridgetown. For example, there are new minimum versions of both Ruby and Node for the v2 release cycle.

(Note that some of the new features/enhancements would benefit from detailed documentation which is still underway. We'll have things more fleshed out by the final 2.0 release.)

### What's Been Added

We've made it possible for **Roda routes** to [render "callable" objects](https://edge.bridgetownrb.com/docs/routes#callable-objects-for-rendering-within-blocks) (docs) in a very straightforward manner. In MVP parlance, you can now designate your own "controller" objects to handle any requests, or utilize "view" objects to provide particular kinds of output (and out of the box, resources themselves can be returned directly as responses).

Plus, we've **simplified front matter data access** using new syntax across the system (in Ruby-based templates you can omit `data.` in many cases, e.g. `title` instead of `data.title`), and for Roda rendering in particular it's now _much_ cleaner to [pass data along to templates](https://edge.bridgetownrb.com/docs/routes#file-based-dynamic-routes).

Live reloading in development is **dramatically faster** on average now with the Fast Refresh feature (see the referenced post above for more on how that works).

There's now a go-to inflector to handle various **string conversions** (aka `folder_name/file_path.rb` → `FolderName::RubyFilePath`) [using dry-inflector](https://edge.bridgetownrb.com/docs/configuration/initializers#inflector) (docs).

We've added support for new [Serbea 2.0](https://serbea.dev) template features, including the `pipe` helper which can be used even in ERB templates. And in addition, we now have a **pure Ruby template syntax via Streamlined**. Documentation is forthcoming, but [you can take a peak at what authoring HTML using Streamlined looks like](https://codeberg.org/jaredwhite/streamlined/src/commit/7aed52d4fe60f5315d228075a06b80a3fbc6d816/test/test_streamlined.rb#L32). This is Bridgetown's official answer to techniques like `content_tag` in Rails or gems like Phlex, and it takes a great deal of inspiration from JavaScript's tagged template literals.

### What's Changed

Bridgetown now **defaults to using ERB** in new site projects, rather than the previous default of Liquid. You can choose Liquid (or any supported template engine) when you create a new site, but without specifying a particular option Bridgetown will assume ERB.

The config **YAML file is now optional**—in fact, in new Bridgetown projects only the `config/initializers.rb` file is generated as the primary form of configuration. In addition, previous support for `.toml` files has been removed. We'll be upgrading our documentation to point out these new defaults.

We've significantly refactored the [file-based routes plugin](https://edge.bridgetownrb.com/docs/routes#file-based-dynamic-routes) under the hood for more robust behavior and continuing improvements over time to support **advanced full-stack applications**.

As promised, an initial batch of first-party framework code (i.e., [bridgetown-foundation](https://github.com/bridgetownrb/bridgetown/tree/main/bridgetown-foundation)) to **replace Active Support-based dependencies** has landed. And we're making use of the new [Inclusive gem](https://codeberg.org/jaredwhite/inclusive) to package and import utility code.

Our `start` command now uses Rackup (and [Rack 3](https://github.com/rack/rack)) instead of directly interfacing with Puma. This **paves the way for future developments** such as supporting other Rack-compatible application servers in addition to Puma.

The way we handle front matter has been extracted into **standalone loaders**. This will make it easier to maintain our front matter loaders over time as well as offer the possibility of supporting new front matter formats in the future.

### What's Been Removed

We've removed legacy code dealing with permalinks, along with a variety of other previously-deprecated code paths. We've also **removed Cucumber**, rewriting our integrated feature tests to consolidate around Minitest exclusively. And our Webpack integration is at last done away with, in lieu of a complete focus on esbuild. **End of an era!**

### What's Next

**Bridgetown 2.0 is generally "feature complete" at this point**, although one or two small enhancements waiting in the wings might sneak in before the final release. In general however, we're focusing on fixing bugs and tightening up reliability over the next few weeks as we transition from beta status to production.

Beyond that, the team is working on additional ecosystem functionality with gems such as **Lifeform** (form rendering) and **Authtown** (accounts and logins) which can be used on Bridgetown projects. Our [Sequel gem](https://github.com/bridgetownrb/bridgetown_sequel) for database access is already out the door. And for server-side rendering of web components in Ruby with a companion library offering client-side interactivity…well, that too is forthcoming. 😁

As always, if you run into any issues trying out Bridgetown 2.0 beta, [please hop into our community channels](/community) and let us know how we can help. And if you're new to Ruby, we're happy to recommend other resources and communities which can give you a leg up. We try our best to follow the Ruby language motto: **MINASWAN**. (Matz Is Nice And So We Are Nice…Matz being [Yukihiro Matsumoto](https://en.wikipedia.org/wiki/Yukihiro_Matsumoto), the creator of Ruby.)
