---
date: Wed, 24 Dec 2025 08:22:54 -0800
title: "Bridgetown 2.1 Has Come to Town! Happy Holidays 🥳"
subtitle: "Festive new features, a snappier CLI, under-the-hood refactoring & infrastructure work, and a celebration of Ruby 4.0 as we head into 2026."
author: jared
category: release
---

You better watch out (I’m telling you why): the latest release of our merry little Ruby framework is coming to town! Yes indeed, **Bridgetown 2.1 "Festive River City"** is here, with a marquee feature enabling you to load in wiki-style content & "digital gardens" managed by external applications, and a slew of other improvements. And you'd better believe we're ready for the imminent Christmas release of **Ruby 4.0**!

You can read more about the release details [here in our initial beta post](/release/bridgetown-2-1-beta-1-festive-river-city/), and there are a couple additional details we need to mention:

* We now have a brand-new **Matrix** chat room! Embrace open protocols and [chat with fellow Bridgetowners on Matrix](https://matrix.to/#/%23bridgetownrb:matrix.org). (We recommend you install [Element X for iOS & Android](https://matrix.org/ecosystem/clients/element-x/) so you can access Matrix via mobile platforms.)
* We fully embrace Bridgetown projects configured to bundle gems from alternative community servers like **gem.coop** as well as our own canonical **gems.bridgetownrb.com** server. [Read the details here.](/docs/installation#gem-servers)

[Read the 2.1 release notes here.](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.1.0) To upgrade, make sure you're running at least Ruby 3.2 and Node 22, then modify your `Gemfile`:

```ruby
gem "bridgetown", "~> 2.1.0"
gem "bridgetown-routes", "~> 2.1.0" # if applicable
```

and run `bundle update`. [Upgrade instructions here.](/docs/installation/upgrade) Or you can run `gem install bridgetown -N -v 2.1.0` and then create a new site.

And of course we continue to push for awareness of "indie web" and sustainable alternatives to Big Tech solutions. Our documentation now includes [information on how to deploy](/docs/deployment#statichosteu) static Bridgetown sites to [statichost.eu](https://statichost.eu), and our Automations feature can load automation scripts from Codeberg and GitLab repositories in addition to GitHub.

If you run into any issues trying out Bridgetown 2.1, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us on Bluesky](https://bsky.app/profile/bridgetownrb.com) and [the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.

**Happy Holidays! See y'all in the New Year!** 🎉 🎆
