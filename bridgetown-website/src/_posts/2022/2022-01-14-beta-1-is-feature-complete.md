---
title: What’s New in “Feature Complete” Bridgetown 1.0 Beta 1
subtitle: We’re on a fast track to a final 1.0 production release, and we have a brand new website to go along with it! Keep reading to learn all about the latest goodies.
author: jared
category: release
---

Big **ch-ch-ch-ch-changes** around here in 2022! For starters, **we have a brand new website**! Huge shoutout to [Adrian Valenzuela](https://adrianvalenz.com) for his work on the refreshed Bridgetown logo and branding guide, and [Whitefusion](https://www.whitefusion.studio) (which, full disclosure, is my little Portland-based web studio) for the overall design & development of the website. We'll have more to share about the process of creating the new look and a peek under the hood in the days ahead.

But on to the main event: **Bridgetown 1.0 "Pearl" Beta 1 has arrived**. [Fresh installation instructions are here](/docs/installation). To upgrade from a previous version of 1.0, simply:

```sh
bundle update bridgetown
```

You'll also need to run `bin/bridgetown webpack update` to get the latest default Webpack configuration installed. Or…if you're feeling ambitious, you might want to migrate off Webpack and start using esbuild instead! (More on that in a moment…)

To upgrade from Bridgetown v0.2x, we now have an [offical upgrade guide](/docs/installation/upgrade) which we'll be amending as feedback comes in.

**A quick word on the state of things**: we now consider v1.0 to be "feature complete". In other words, the beta cycle we're in now is solely to fix showstopper bugs or add _very minor_ enhancements which directly improve daily quality of life when using Bridgetown. We're on a fast track to a final 1.0 production release, though thanks to a lengthy alpha release cycle we feel pretty confident Beta 1 is already production quality for the most part. YMMV.

The reason reaching 1.0 is such a Big Deal is because we're taking [SemVer](https://semver.org) seriously. This means we're done tinkering with significant aspects of the underlying codebase, Ruby API, and user-facing feature set. With the final release of 1.0, we want the community to feel confident it's time to get cracking building plugins, writing tutorials, recording screencasts, designing themes, and generally contributing to the larger body of resources which help Bridgetowners build websites quickly and painlessly.

With that out of the way, on to what's new in Beta 1. (For more on what's new in v1.0 to date, [check out this blog post](/release/era-of-bridgetown-v1/).)

### ERB from Day 1 (and a new blank site template!)

Beta 1 adds the ability to pick a template engine other than Liquid right when you start a new Bridgetown site. Simply use the `-t`/`--templates` option and pick `erb` or `serbea` when running `bridgetown new`. For example:

```sh
bridgetown new site_using_erb -t erb
```

Regardless of which template engine you choose, we also have a nice new "blank site" template which looks good enough that you could actually just slap some Markdown content on there and call it a day for a _super-dee-dooper_ simple website. Obviously it's still easy enough to blow everything away and start fresh with your own design.

More documentation on [template engines here](/docs/template-engines).

### Frontend Bundling via esbuild by Default

For many people the marquee feature in Beta 1 is the arrival of our official **esbuild** integration. Now truth be told I personally haven't had much of an adversarial relationship with Webpack. It's gotten the job done (and reasonably quickly) in the applications I've worked with.

But not everyone's experience with Webpack has been as rosy as mine, plus it's undeniable esbuild has gained huge momentum lately as a super-speedy and pliable tool for bundling frontends (aka your CSS/JS/icon/font/etc. assets). So it is with great pleasure that I announce that not only did we build an esbuild integration every bit as solid as our Webpack integration, but _we decided to switch defaults_: from now on, all new Bridgetown sites will come with esbuild out-of-the-box. If you still want/need to choose Webpack, just pass the `-e webpack` flag to `bridgetown new`.

It wasn't an easy decision to add esbuild support. You see, we don't just plop any ol' frontend bundler in your project and let you deal with it. We hand-craft bespoke default frontend configurations which are intended to support a wide array of Bridgetown frontend needs with virtually no tweaking required by individual developers, and we provide an infrastructure to _upgrade_ that default config over time as we make improvements. So by adding esbuild support without dropping Webpack, we've taken on the responsibility of maintaining not one but _two_ significant frontend configurations. We've done this because we believe strongly in the [backpack analogy](/docs/philosophy#core-principles). To quote: "if you have to go fishing for a bunch of extra plugins and add a slew of extra libraries and reconfigure settings just to complete basic setup tasks, we’re doing it wrong."

For a little more background on _why_ esbuild and _why not_ other concepts like supporting import maps, [read this blog post](/feature/progress-report-esbuild-aware/#so-about-that-esbuild-line-item).

**FYI:** if you're already using PostCSS with Webpack, there's an experimental migration command to let you switch from Webpack to esbuild right away! Just run:

```sh
bin/bridgetown esbuild migrate-from-webpack
```

For Sass users, we don't yet officially support it at all with esbuild. We're optimistic support will land before the final release of 1.0, but we're not promising anything at this time.

More documentation on [frontend bundling here](/docs/frontend-assets).

### Improved DX When Errors Arise

While not as flashy as the other two features, I greatly appreciate this improvement.

Let's face it: error messages suck. The only question is how much they suck. The most we can hope for when attempting to improve in this area is getting them to **suck less**. In Beta 1, we worked on a couple of aspects to move the needle in the right direction:

(**a**) **Eliminate unnecessary backtraces.** Most of the time when an exception is raised, the offending line is only a level or two deep in your own code stack. The rest of the backtrace information is a waste of your time and screen real estate (aka you really don't need to know about which part of Rake, or Thor, or the Bridgetown build command, etc. happened to lead to your error). So we now only include the first 5 lines or so, formatted a little better to boot. And if you _really_ need all that extra trace info for whatever reason, just use the `-t` flag.

(**b**) **Fix problems with getting a clean trace.** We noticed several cases where the error being reported wasn't really the right error (aka an exception was getting swallowed in once place but then triggering a problem in another place), or the message itself was obtuse (aka missing relevant class names or other helpful context). This was most notably true with errors in Ruby components or in view templates. We've made some big improvements in those areas in Beta 1 and will prioritize further fixes in this area.

If you come across any super-confusing or misleading error messages while using Beta 1, please let us know!

### Wrapping Up the Beta Cycle

Our goal is to move swiftly through the beta release cycle and get to a final, production-ready 1.0 release within the next month or so. This means your feedback is critical during this time to find and fix showstopper bugs as well as improve documentation (and believe me, there's still room for improvement!). Please visit our [Community page](/community) to find out how to submit feedback, request help, and report issues.

Thanks to all who have contributed, whether financially, or with ideas, or with code, to Bridgetown in the lead-up to v1.0. We appreicate all that you've done thus far and can't wait to see what you build next!