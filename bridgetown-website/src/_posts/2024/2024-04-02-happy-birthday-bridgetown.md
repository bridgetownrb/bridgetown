---
date: Tue, 02 Apr 2024 08:09:29 -0700
title: Happy 4th Birthday, Bridgetown!
subtitle: A hearty thank you to all our sponsors and 70+ contributors who have helped this open source project flourish.
author: jared
category: news
---

Four years ago today, I wrote in my Day One journal:

{%@ Note do %}
“I forked **Jekyll** today and turned it into **Bridgetown**, so I'm now privately the maintainer of a Webpack-aware, Ruby-based static site generator for the modern JAMstack era. How cool (and crazy) is that?!?!”
{% end %}

The first public website launch and release of Bridgetown 0.10 [happened a few weeks later](/news/time-to-visit-bridgetown/), and the rest as they say is history. As always, a **hearty thank you** to all our [sponsors](https://github.com/bridgetownrb/bridgetown#special-thanks-to-our-github-sponsors--) and [70+ contributors](https://github.com/bridgetownrb/bridgetown/graphs/contributors) who have helped this open source project flourish in ways I never could have imagined.

## Some "hindsight is 20/20 thoughts"

I know we all sort of cringe thinking about Webpack today (_esbuild forever!_), but back then it was still a Big Deal and represented a major frontend shift towards using ESM, pulling in packages from NPM for both JavaScript and CSS libraries/frameworks, and compiling using JavaScript-based tools. Having a pre-configured frontend pipeline that Just Works™ come ready to roll with your site generator was (and is) nothing to sneeze at.

It's interesting to look at my original notes on what was most urgent to add to whatever might emerge from this fork: Webpack (as mentioned), Components (not just basic includes/partials), Internationalization (i18n), and easier third-party API integration were top of the list. A promising start! But a lot of what I love today about Bridgetown hadn't quite been conceived of yet. **Much has happened in only four years!** (You can find a more in-depth [list of post-Jekyll features and changes here](/docs/migrating/features-since-jekyll) if you're curious.)

One major direction for Bridgetown I imagined in those earlier days that we ended up totally shifting away from is a tight integration with Rails. Aside from my [own perspective on Rails shifting](/future/road-to-bridgetown-2.0-escaping-burnout/), it turns out a significant level of interest in the potential architecture such a marriage might produce never materialized. I could do a deep dive some day into why that might be, but the good news (and a direction I never would have foreseen in 2020!) is that we pivoted into a tight integration with [Roda](/docs/routes). That proved to be a **huge boon** for the framework—with a lot of newer features being heavily inspired by the "Roda way" like the new [Initializers](/docs/configuration/initializers) system—and **I'm ready to push that all to the max this year**. I see no reason why, with just a tad more DX polish, a combined Bridgetown + Roda couldn't be then used to build _substantial_ web applications serving thousands of customers. I look forward to spreading the message that Bridgetown is far more than "just" a static-site generator (as we clearly say right on our homepage!) by promoting solid integrations with [Rodauth](http://rodauth.jeremyevans.net) and [Sequel](http://sequel.jeremyevans.net) to round out our server-side offerings. (We're basically just living in the JECU—the Jeremy Evans Cinematic Universe—at this point! 😅)

## In closing…

We're currently in the midst of the Bridgetown v2 development cycle, and I'll be posting Part 3 of our blog series on the topic shortly. In the meantime, be sure to sign up on our [Community Discussion site](https://community.bridgetown.pub) and [follow us on Mastodon](https://ruby.social/@bridgetown) to stay on top of the latest news. **Thank you once again for all of your support over the past four years**. The Bridgetown community is now larger than any one of us, and I can't wait to see what the next four years have in store for Rubyists everywhere.
