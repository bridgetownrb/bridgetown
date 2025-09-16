---
date: Tue, 16 Sep 2025 09:01:23 -0700
title: "Good Times in River City: Bridgetown 2.0 is Here!"
subtitle: "Introducing the only Ruby web framework which bridges the gap between static Markdown sites and fullstack database-driven application deployments."
author: jared
category: release
---

<figure style="max-width: 840px; margin: 0 auto 2.5em">
  <img src="/images/river-city-postcard-bridgetown.jpg" alt="Greetings from River City! Bridgetown v2 Web Framework" style="display: block; box-shadow: 0px 10px 30px rgba(0,0,0,0.2); border-radius: 4px">
  <figcaption style="font-size: 80%; margin: 0.5rem; text-align: right"><a href="https://adrianvalenz.com" target="_blank">Graphic Design by Adrian Valenzuela</a></figcaption>
</figure>

Introducing the only Ruby web framework which bridges the gap between static Markdown sites and fullstack database-driven application deployments: **Bridgetown 2.0 "River City" has been released!** 🎉 This version has long been in the hopper, and it's chock full of major quality-of-life improvements ([check out the release notes!](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.0.0)). Start your first Bridgetown site with our [installation guide](/docs), or upgrade your site by bumping the version in your Gemfile:

```ruby
gem "bridgetown", "~> 2.0"
gem "bridgetown-routes", "~> 2.0" # if applicable
```

and running `bundle update`. [More upgrade details here](https://edge.bridgetownrb.com/docs/installation/upgrade), including switching from Yarn to NPM and from CommonJS to ESM for a modern, streamlined frontend build system. If you run into any issues, [hop in our Discord chat](https://discord.gg/4E6hktQGz4) and let us know how we can help you!

{%@ Note do %}
**A huge thank you to our many contributors!** 🎉 ayushn21, KonnorRogers, michaelherold, erickguan, MaxLap, jeremyevans, brainbuz, akarzim, surrim, mlitwiniuk, jaredcwhite, and everyone who submitted bug reports and feedback. We couldn't have done this without you!

Also, if you're brand-new to the Bridgetown 2.0 release cycle, [read our Road to Bridgetown 2.0 series here](/blog).
{% end %}

Now without further ado, let's talk about all the new features in **Bridgetown v2 "River City".**

### New Defaults

When you create a new Bridgetown site, you will now get **ERB templates** installed automatically (rather than the previous default of Liquid). We believe this is much more ergonomic for Ruby developers, but if you work with designers who are more familiar with Liquid, that is still officially supported. (For existing sites based on Liquid, add `template_engine :liquid` to your `config/initializers.rb` file or `template_engine: liquid` to `bridgetown.config.yml`.)

Bridgetown now requires a minimum version of Ruby 3.1.4 and Node 20.6. This unlocks a variety of syntax improvements both for our internal Ruby APIs and the Ruby code you write in your projects. And with the Node upgrade, we can now switch our esbuild config from the older CommonJS syntax (aka `require`) to modern ESM (aka `import`) which is the industry standard and much more expected for frontend JavaScript developers. In addition, Yarn is no longer required as a JS package manager—you can switch to using NPM directly which is a far better tool now than it once was. Or if you prefer, `pnpm` which is also supported! (Just make sure you update the `:frontend` tasks in your project's `Rakefile` to use your preferred package manager.)

New sites will default to including just the newer Ruby initializers configuration (`config/initializers.rb`), but the legacy YAML config (`bridgetown.config.yml`) is still supported and may still be required for certain plugins.

Finally, webpack is no longer supported. Bridgetown is all in on esbuild as the "last frontend bundler you'll ever need". Make sure you search-and-replace `webpack_path` to `asset_path` in your templates!

### Fast Refresh

You know how frustrating it is when you fix a simple typo on a large site and then you have to wait 20 seconds for a rebuild? Well I don't, because I've been rocking the betas for months! 😂 But in all seriousness, this is a fantastic new feature in Bridgetown 2.0, based on a pair of techniques called _signals_ and _effects_ to track changes to individuals files and the ways in which data can flow across multiple files.

In not all, but in most cases, **this results in a much faster rebuild time.** If you edit just a single resource file, it's likely only that one resource will get rebuilt. Using the new `site.signals` API, you can edit data files and only the pages loading in that data will get rebuilt. Fast refresh also tracks access to components within templates. [Read our original announcement blog post](/future/road-to-bridgetown-2.0-fast-refresh/) for a deep dive into this functionality.

### Superior Roda Integration

Bridgetown provides a [full SSR pipeline built on top of the Roda web toolkit](/docs/routes). You can handle form data or JSON payloads with ease, or power up our dynamic, file-based routing with all of Bridgetown's template engines and component rendering at your disposal.

This was all true prior to 2.0, but what's new is we've added a lot more smarts to Roda for building object-oriented backend APIs out of modular building blocks. You can keep the Roda routing tree lean-and-mean and rely on "controller" and "view" style objects for a familiar pattern to fullstack application development. Want to access a database like PostgreSQL? Our new [bridgetown_sequel plugin](https://github.com/bridgetownrb/bridgetown_sequel) is the answer you seek. 

Check out our [Roda reference guide](/docs/roda) as well as our updated [Routes guide](/docs/routes) to get up to speed.

### Streamlined

This is a [new library](https://codeberg.org/jaredwhite/streamlined) installed with Bridgetown for embedding HTML templates in pure Ruby code using "squiggly heredocs" along with a set of helpers to ensure output safety (proper escaping) and easier interplay between HTML markup and Ruby code. **And it's fast: roughly 50% faster than ERB!**

You can use Streamlined directly in resources saved as pure Ruby (`.rb`), as well as in Bridgetown components. Here's an example of what that looks like:

```ruby
class SectionComponent < Bridgetown::Component
  def initialize(variant:, heading:, **options)
    @variant, @heading, @options = variant, heading, options
  end

  def heading
    <<~HTML
      <h3>#{text -> { @heading }}</h3>
    HTML
  end

  def template
    html -> { <<~HTML
      <section #{html_attributes(variant:, **@options)}>
        #{html -> { heading }}
        <section-body>
          #{html -> { content }}
        </section-body>
      </section>
    HTML
    }
  end
end
```

You may still prefer to author HTML in a "markup first" manner with embedded Ruby, rather than Ruby with embedded HTML (and sometimes I do), but for components with complex interpolations, Streamlined is a win. [Read the new documentation here.](/docs/template-engines/erb-and-beyond#streamlined)

### Foundation Gem

In Bridgetown 2.0, we have started an ongoing process of reducing our reliance on the Active Support gem (in the hopes we can eventually remove it as a dependency). The **Foundation gem** marks our effort in this department, and not only that but we'll be increasingly migrating other useful utility-like Ruby features there from internal Bridgetown APIs so that they're more decoupled and easily accessible to non-Bridgetown Ruby applications. [Foundation gem docs are available here.](/docs/plugins/foundation-gem)

### Ecosystem Update (Hello Codeberg!)

We've had a goal in mind to embark on a **major revamp of our Plugins directory** as well as offer a program to help new plugin authors get started and eventually featured in official Bridgetown marketing. While those ideas were brewing, a huge shakeup has started in the open source community. Due to Microsoft's major "vibe shift" with how it stewards GitHub—essentially embarking on a "pivot to AI" and folding the company into its own AI & cloud departments, many open source developers are looking elsewhere for a true _libre_ alternative. (It's odd when you stop and think about it that a _proprietary, closed-source platform_ would be the defacto home for open source projects!)

The destination folks are heading for more and more is [Codeberg](https://codeberg.org), a European organization which runs a forge built on top of the fully open source [Forgejo software](https://forgejo.org) (itself a fork of Gitea). Codeberg has really seemed to reach escape velocity this year, and I (Jared) have already [migrated a number of projects there](https://codeberg.org/jaredwhite/.profile/projects/22897), including several low-level Bridgetown dependencies.

We don't feel comfortable with the idea of relocating the **Bridgetown monorepo** itself at this time, out of concern that it will be cumbersome for existing and potential contributors. But the Bridgetown core team is committed to keeping a close watch on how this movement unfolds. One of the most exiting future developments will be _federation_, the idea that multiple forges run by individuals and organizations alike could all communicate with each other, sharing issues and PRs as if it were all a single platform (just like Mastodon instances!). We believe this will be a seismic event in the evolution of code forges and signal the beginning of the end of GitHub's dominance in the open source community. As they say, _stay tuned_.

### Et Cetera and So Forth

([There's much more in the release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.0.0)) showing a large number of bug fixes and refactors for performance and DX, and while software is of course never "done", we are **extremely proud** of the Bridgetown 2.0 release and consider its full feature set to be the culmination of several years of effort. It's likely we'll continue to chip away at the margins of smaller fixes and enhancements for a long while yet in the v2 era, but the bottom line is that **Bridgetown is a mature and stable foundation** on which to build the next generation of static sites and modest web applications, always with HTML-first and "vanilla web" principles in mind.

If you run into any issues trying out Bridgetown 2.0, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us now on Bluesky](https://bsky.app/profile/bridgetownrb.com) as well as [in the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.
