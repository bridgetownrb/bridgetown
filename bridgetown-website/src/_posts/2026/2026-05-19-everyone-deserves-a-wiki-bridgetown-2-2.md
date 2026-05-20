---
date: Tue, 19 May 2026 12:37:46 -0700
title: "Everyone Deserves a Wiki: Bridgetown 2.2 is Here"
subtitle: "Wikilinks in Markdown, support for Falcon the highly concurrent Ruby web application server, performance enhancements, bugfixes, and more!"
category: release
author: jared
image: /images/verdant-river-city.jpg
---

<figure style="max-width: 840px; margin: 0 auto 2.5em">
  <img src="/images/verdant-river-city.jpg" alt="Verdant River City: Bridgetown v2.2" style="display: block; box-shadow: 0px 10px 30px rgba(0,0,0,0.2); border-radius: .75rem">
  <figcaption style="font-size: 80%; margin: 0.5rem; text-align: right"><a href="https://pixelfed.social/@essentiallife" target="_blank">Photography by Jared White</a></figcaption>
</figure>

Springtime in Portland is always a true delight, and the perfect backdrop for our newest release of **Bridgetown, version 2.2**.

When it came time to decide on the codename for the release, we just couldn't bear the thought of moving away from our beloved "River City" moniker. Mere months after our massive version 2 launched, we released 2.1 during the 2025 holiday season and called it "Festive River City". And we knew we needed to keep this tradition alive just a little bit longer.

So we turned to our _crack marketing team_, loaded them up with local apple cider and Oregon Marionberry scones, locked them in a chill café adjacent to a food cart pod, and let them work their special brand of magic. After many, many long hours of heightened debate, they solemnly informed us they had arrived at a winner. And winner it is indeed.

Introducing **Verdant River City**, the latest iteration of the Bridgetown Ruby Web Framework.

[Read the 2.2 release notes here.](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.2.0) To upgrade, make sure you're running at least Ruby 3.3 and Node 22, then modify your `Gemfile`:

```ruby
gem "bridgetown", "~> 2.2.0"
gem "bridgetown-routes", "~> 2.2.0" # if applicable
```

and run `bundle update`. [More upgrade instructions here.](/docs/installation/upgrade) Or you can run `gem install bridgetown -N -v 2.2.0` and then create a new site.

### Hyperlink with Aplomb

The marquee new feature of Bridgetown 2.2 "Verdant River City" is support for _wikilinks_. It's a syntax which makes it easy to add links when authoring any Markdown file. No longer do you need to keep track of filenames or URLs. Just type `\[[Page Title Goes Here]]` and Bridgetown will automatically locate a resource with `title: Page Title Goes Here` in its front matter. You can of course [add additional syntax to customize the text of the link](/docs/resources#wikilinks) if the title isn't suitable, as well as link to a specific section/anchor within the resource.

Wikilinks pairs well with our previous release's support for [external content sources](/docs/content/external-sources). It's now possible to author a file-based "wiki" entirely with outside applications, point to those files from a Bridgetown project, and publish that wiki as a public (or internal!) website—perfect for knowledge bases, digital gardens, academic archives, and so much more.

### Soar with Falcon

In Bridgetown 2.2, we have migrated a new default server, Falcon. (Don't worry: existing projects still on Puma will still run without issue\*. You can migrate, or not, at your leisure!)

Falcon is a new highly concurrent Ruby web application server. While Puma serves a request per thread, Falcon uses fibers which are an order of magnitude cheaper to create. Falcon also supports HTTP/2 naively. This combined with its highly concurrent architecture means it's viable to serve internet traffic using Falcon itself instead of another webserver such as Caddy in front of it.

Falcon has been battle-tested at Shopify and [used to serve Black Friday traffic](https://speakerdeck.com/ioquatix/surviving-black-friday-329-billion-requests-with-falcon), and as such we believe it's the future for the Ruby ecosystem. It also paves the way for Bridgetown to support a deployment story where the website is served using Ruby code end-to-end.

If you'd like to try out Falcon in your existing Bridgetown project, remove `gem "puma"` from your `Gemfile` and add `gem "falcon"`. After a `bundle install`, you can use Bridgetown exactly as before, only now it will detect you have Falcon installed and use that instead of Puma!

\* Due to underlying server layer refactoring, you may occasionally see a Puma "thread error" notice when pressing Ctrl+C to terminate the dev server. It's harmless, but any unwanted noise in your terminal isn't OK with us, so we'll track that down and include a patch in the next point release.

### Bridgetown Sites in the Wild

It's been a busy time for the Bridgetown ecosystem! Rubyists everywhere are turning to Bridgetown to serve their publishing needs, including:

* [Sidekiq](https://sidekiq.org/)
* [RuboCop](https://rubocop.org/)
* [Rocky Mountain Ruby](https://rockymtnruby.dev/)

We're also a featured framework now within the Ruby Users Forum! [Read the full announcement here.](https://www.rubyforum.org/t/bring-your-bridgetown-discussions-to-the-ruby-users-forum/301)

### New Sponsorship Opportunity!

We are slowly moving off of promoting GitHub Sponsors as the canonical way of supporting Bridgetown financially. We will incrementally investigate systems & opportunities to ensure the continued sustainability of the ecosystem, and in a first step to that end, [you can now become a sponsor through Liberapay.](/sponsor)

**Our first goal: $400/month**. We actually exceeded this goal once before using GitHub Sponsors, but, well, the last couple of years have been hard on everyone in independent open source. But we believe this goal is achievable again, and once we reach it…_we'll aim for the next goal!_ 💪

### But That's Not All Folks…

There is in fact _another_ major announcement we're making at this juncture beyond the release of 2.2, and that's the launch of the [**Bridgetown Center** plugin program](/plugins/center). But we'll save that for another blog post. =)

----

**Thank you for your interest in Bridgetown 2.2!** In addition to the features mentioned previously, we've been fixing bugs, improving performance, and generally making the experience of using Bridgetown even better. [A huge shoutout to all the contributors who made this release possible.](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.2.0) 

If you run into any issues, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us on Bluesky](https://bsky.app/profile/bridgetownrb.com) and [the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.

Additional credit to [Ayush](https://ruby.social/@ayush) for assistance in the writeup regarding Falcon.
