---
title: Say Hello to Ruby 3 and PostCSS in Bridgetown v0.19 “Arbor Lodge”
subtitle: |
  Our final release of 2020 and a hint of what is to come in 2021. Plus some thoughts on NEW MAGIC. What a time to be a Rubyist!
author: jared
category: release
---

Happy Holidays, Merry Christmas, and Joyful Rubyist Tuesday (is that a thing?) as we celebrate the release of Bridgetown 0.19, codenamed "Arbor Lodge".

Two main features stand out:

* **Support for Ruby 3.** We've fixed bugs and patched gems to make sure Bridgetown works with Ruby 3 right out-of-the-gate. Once you install Ruby 3 ([currently in release candidate stage](https://www.ruby-lang.org/en/news/2020/12/20/ruby-3-0-0-rc1-released/)) and upgrade to v0.19, everything should just work\*. Support for Ruby 3 is mixed among the prominent Jamstack hosts at present, so we consider this slightly experimental in terms of production readiness. But it's a perfect time to start tinkering! BTW, if you run into any bugs specific to Ruby 3, or even earlier Ruby versions as a result of our Ruby 3 changes, [please file an issue](https://github.com/bridgetownrb/bridgetown/issues/new/choose) so we can address them right away.
* **Support for PostCSS.** With the `--use-postcss` option added to `bridgetown new`, you can start your site off with a configuration well-suited to the latest crop of frameworks and "next-gen" CSS methodologies. We know how popular Tailwind has become with some web developers, and now getting it up and running will be a cinch. Sass is still available as the default option.

See our [release notes on GitHub](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.19.0) for a full changelog.

\* There's a bug in the Thor gem preventing remote automations to run via the `bridgetown apply` command. However, you can add our patch to your Gemfile while waiting for an official Ruby 3-compatible Thor update.

```ruby
gem "thor", github: "jaredcwhite/thor", branch: "apply-patch-for-ruby-3"
```

### Introducing Our Latest Core Team Member

In addition to the new release, we also have a new core team member! Welcome, 
[Ayush Newatia](https://github.com/ayushn21). Ayush is the driving force behind our new PostCSS integration and has already contributed many super ideas which are helping shape the future of Bridgetown. Ayush is also based in the UK which means our core team is now officially global. 🌍 [Hop on over to our Discord chat to say Hello](https://discord.gg/V56yUWR).

We're also grateful for our latest crop of sponsors on GitHub! [pascalwengerter](https://github.com/pascalwengerter), [DRBragg](https://github.com/DRBragg), and [jasoncharnes](https://github.com/jasoncharnes): you rock! 🤘 (P. S. It's not too late to [join the merry crew](https://github.com/sponsors/jaredcwhite/)!)

### A Word on "NEW MAGIC"

Today also marks the day DHH and the intrepid pioneers at Basecamp have released their "NEW MAGIC" — now officially named [Hotwire](https://hotwire.dev). Comprised of Turbo (the modern successor to Turbolinks) and Stimulus, with full Rails integration, it's an exciting method of building slick, reactive applications in Ruby with only a "sprinkling" of JavaScript.

We're big fans of reactive Ruby. StimulusReflex showed us what's possible with mere lines of code, and Hotwire is yet another take on how to push Rails to its limits. But there's just one problem with those approaches as-is: at the end of the day, you're only building dynamic, server-based applications. What if you also want a static frontend deployed on Jamstack architecture? For some applications, it makes sense to prerender content and serve it up on a global CDN for crazy-fast performance and minimal cost…with a backend only there to assist with some specific interactive bits like a checkout page, a customer portal, or a live stats dashboard.

Some people will tell you you have to switch to a JavaScript-based framework to accomplish that. Perhaps Next.js or Gatsby. We envision a better way, [which we jovially refer to as the DREAMstack](/release/the-future-of-bridgetown-today-in-0.18-taylor-street/#the-future-of-the-ruby-view-layer). **Delightful Ruby Expressing APIs & Markup**.

Our primary goal in early 2021 is to finish retrofitting Bridgetown to support a dynamic backend integration at any point in your development process. Start out with a basic Bridgetown site, and then add a suitable Rails API _whenever you need it_. Same repo, same Gemfile, same Ruby. Share a unified view layer between the two. Dynamically re-render Bridgetown pages or components only when required. And now with Hotwire, your Bridgetown site has the possibility become _reactive_ with only a few extra lines of code. Living the DREAM!

Stay tuned for our official announcement and "Dreamstack" hosting options soon. In the meantime, enjoy the holidays, have fun with Bridgetown 0.19, and we'll catch you in the new year. 🥳