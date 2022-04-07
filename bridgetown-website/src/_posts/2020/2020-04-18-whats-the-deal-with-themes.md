---
title: What's the Deal with Themes?
subtitle: Why Bridgetown is making a clean break with the past and building an entirely new framework for creating and using themes.
author: jared
category: future
---

If you're familiar with Jekyll—or really any web publishing system out there—you're no doubt familiar with the idea of a _theme_. You browse a collection of themes, find one that looks good, go to your website tool and press a button/type a command/upload a package, and _presto change-o_! You've got yourself a shiny new website. Everybody loves themes, right?

The problem with this simplistic explanation is that it's almost never the full story. There are as many ways of implementing and using themes as there are publishing systems which support them. And sometimes what is called a "theme" over here bears little resemblance to a "theme" over there.

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
Some themes are really visual page builders not meant for developers.

{:.has-text-weight-medium.is-size-5.my-8}
Some themes are entire frameworks for building website UI and layout.

{:.has-text-weight-medium.is-size-5.my-8}
Some themes force strict requirements on how to structure content.

{:.has-text-weight-medium.is-size-5.my-8}
Some themes are essentially a collection of modules expressly intended for developer customization.

{:.has-text-weight-medium.is-size-5.my-8}
Some themes are hard to customize because scripts and stylesheets are pre-generated or bespoke one-off code.

{:.has-text-weight-medium.is-size-5.my-8}
Some themes can be assigned to a site at any time.

{:.has-text-weight-medium.is-size-5.mt-8.mb-10}
Some themes are installed when a site is created.

So the question then becomes not _where_ to get a theme or _how_ to build a theme, but _WHY_ a theme? ([Good one Drax.](https://youtu.be/0684dMzFxo0))

### Jekyll "Themes"

When I got started with Jekyll back in 2015, a "theme" was basically just a "starter kit". You'd clone a repo or download a zip and get a complete Jekyll website. What you did with that site code from that point forward was entirely up to you. That might sound incredibly basic, but it _worked_. A number of marketplaces for free or paid Jekyll themes had been up and running for years, and you could locate a decent starter kit for wide variety of use cases.

When Jekyll 3.2 was released in summer of 2016, it introduced an entirely new Gem-based mechanism for themes. With this added functionality, you could package up a gem with site templates, stylesheets, and assets (aka images, fonts, etc.), and then users could simply `bundle add` your gem, set `theme: awesome-template` in their config file, and _presto change-o!_ A shiny new website design. Plus any time you updated the theme, any user of the theme could update their site with the latest theme changes.

But as you can imagine, this introduces a big problem. What if set your site up with a theme and then want to make a change to one of the theme files? The answer is you'd have to copy file(s) out of the Gem folder on your computer and into your own site repository. It's nice you can do that, but try doing that a few different times and _the entire reason for using a Gem-based theme goes out the window_. Why would you ever want to later update the theme from upstream and get an **unknown combination** of missing updates (due to your custom overrides) plus potential **design breakage** due to unforeseen differences in the updated theme files?

The other conundrum with the way Jekyll added theme support was you could only have one theme configured at a time. In other words, no `themes:` option…just one theme and one theme only. So if a Gem simply wanted to provide some templates for blog posts and another Gem wanted to provide templates for team members, no can do.

That's why even now, long after the release of Gem-based themes, many (most?) Jekyll themes are _still starter kits_, not a theme you'd add to your existing site with the `theme:` config. In the end, for a large variety of use cases, it's just not worth the hassle.

### But we still want to offer themed websites, right?

Yes indeed! Which is why **Bridgetown**—having stripped out the past implementation of themes introduced in Jekyll 3.2—is _headed in an entirely new direction_. Our intention is to take both concepts of themes described above and cleanly separate them out, while making both easier _and_ more powerful:

{:.my-8}
**Starter Kits.**{:.has-text-weight-medium.is-size-5} &nbsp;We're big believers in the idea of _starting_ with a ready-to-go website foundation and then customizing it to the moon and back. That's why we're first going to focus on beefing up the process of using starter kits. We'd like to crib [some great ideas from Ruby on Rails]( https://edgeguides.rubyonrails.org/rails_application_templates.html) as well as other popular static site generators and make it easy to type just a few `bridgetown` commands and have it download, install, configure, and finally present you with a new shiny themed website ready to roll and tweak away.

{:.my-8}
**Theme-ified Plugins.**{:.has-text-weight-medium.is-size-5} &nbsp;Many casual users of Jekyll over the years haven't realized just how powerful Jekyll's plugin system could be—no doubt due to the unfortunate fact that [custom plugins have never been supported by GitHub Pages](https://help.github.com/en/github/working-with-github-pages/about-github-pages-and-jekyll) (unless you set up your own Jekyll build process). Bridgetown inherits this robust plugin system and we're keen to extend it even further. But in addition to simply providing automated content generation or extensions to Liquid templates, _wouldn't it be awesome if a plugin could also supply theme files?_

Imagine adding a `cool-new-plugin` Gem to your site and suddenly you have a new navigation bar to use…or a portfolio page…or an interactive map of all the places you've traveled…or, well, the sky's the limit!

This is no small feat because, in addition to allowing multiple plugins to supply templates and assets, we also need to integrate plugins into Bridgetown's new Webpack pipeline. Getting templates, Ruby code, Javascript, stylesheets, images, etc. all working together in harmony across an advanced website build with numerous plugins is going to be a massive undertaking, no doubt about it. **But we think the end result will be well worth the effort.**

If you have any feedback or ideas about themes in Bridgetown, please drop by [our community forum](https://www.bridgetownrb.com/community) and let us know, or head over to the [Bridgetown repository on GitHub](https://github.com/bridgetownrb/bridgetown) and contribute to the project!