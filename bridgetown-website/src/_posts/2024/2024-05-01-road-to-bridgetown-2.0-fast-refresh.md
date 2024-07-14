---
date: Wednesday, May 1, 2024 at 9:44:34 AM PDT
title: Road to Bridgetown 2.0, Part 3 (Fast Refresh)
subtitle: Saving a file often regenerates so quickly that by time you switch back to your browser, it's already been refreshed. Cool!
author: jared
category: future
---

So before I get right into it, I'm happy to report that **Bridgetown 2.0 development progress is proceeding at a rapid pace!** Many of the features talked about in the previous rounds ([here](https://www.bridgetownrb.com/future/road-to-bridgetown-2.0-escaping-burnout/) and [here](https://www.bridgetownrb.com/future/road-to-bridgetown-2.0-new-baselines/)) are well underway, alongside some significant quality of life DX improvements which will make this release really sizzle. Plus I'm looking forward to blogging about some of the underlying particulars soon at the recently rebooted [Fullstack Ruby](https://www.fullstackruby.dev).

Right, now to the topic at hand. I'll get this out of the way: the **Fast Refresh** feature—a default setting for the development server coming in v2.0—is _not_ like [HMR](https://vitejs.dev/guide/features.html#hot-module-replacement) (Hot Module Replacement), a popular strategy for JavaScript frameworks to make reloading changed code speedy during development. This is in part because—aside from any actual JavsScript files you may have for your frontend—Bridgetown doesn't use JavaScript.

Bridgetown uses Ruby, and to be precise, is based on "old-school" principles of static site generation. (Unless we're talking about dynamic routes served via Roda…we'll save that for a future discussion!) The way it works is you have a repo with a **wide variety of input files**—Markdown, CSV, HTML templates, images, other assets—and a **build process transforms all of those input files** in a variety of ways and then outputs them in formats suitable for a functioning website. In that sense, to "reload" a site after making a file change means to go through that _entire build process again_. For a small site, a full rebuild might be relatively quick…or it might be quite slow if you have **hundreds or thousands of pages and assets** to deal with.

### Where We've Been

Bridgetown's progenitor, Jekyll, offers a limited scope of understanding around the types of content & code to rebuild on-demand as it doesn't come with any frontend pipeline and doesn't provide any "live reload" functionality at all for the browser—nor will Jekyll reload Ruby extensions in a repo when you change that code. However, what Jekyll does have—as do many SSGs out there—that Bridgetown hasn't had to date is an optional **"incremental" regeneration process**—that is, a change to a content file (Markdown, etc.) doesn't necessarily require rebuilding the entire site from scratch. But even that can come with [limitations](https://jekyllrb.com/docs/configuration/incremental-regeneration/), and in many cases a change to a file doesn't trigger the neccessary downstream changes elsewhere—aka you might revise a headline in Markdown file over here, and over there a template which references said headline would still display the old content.

**Stuff like that really grinds my gears.** It's why Bridgetown hasn't offered an incremental regeneration feature or fast refresh or whatever you want to call it. **Trust is the issue.** I want to feel confident that the content I'm viewing in development is as _accurate_ as possible, and to a certain degree, you can't ever trust that what you're seeing is actually correct when anything less that a _full, from-scratch rebuild_ has occured.

Nevertheless, it's admittedly a serious UX fail when sites get larger and larger and you suddenly realize that when you **fix a typo in a Markdown file** you now have to wait **8 seconds** before you see that fix appear in the browser. _Unacceptable!_ In an ideal world, you wouldn't have to wait 8 seconds. Hopefully you wouldn't even need to wait 800 milliseconds. The refresh would occur as close to "instantaneously" as possible.

**That's the goal with Fast Refresh in Bridgetown 2.0.**

How did we accomplish this feat? Read on…

### Signals (Of Course 😏)

The concept of [Signals has taken the frontend world by storm](https://www.spicyweb.dev/videos/2024/signals-are-eating-the-web/), and that shift has started to ripple outward into other computing contexts as well. So what are signals? In a nutshell, **signals** are _reactive variables_—aka values which, when mutated, cause all subscribers to be notified. If you're familar with the simpler pattern of observables, you know you have to set up subscriptions by hand—a tedious and sometimes error-prone endeavor. Signals instead are regularly paired with **effects**—functions which will automatically subscribe to any signals referenced within the function when executed. Later, whenever those signal values change, the effect functions re-execute—_like magic!_ ✨

For a deep dive into this topic from the Ruby perspective, check out [Episode 9 of Fullstack Ruby](https://www.fullstackruby.dev/podcast/8/). TL;DR: thanks to the [Signalize gem](https://github.com/whitefusionhq/signalize) which I wrote as a direct port of Preact Signals, we can use signals in Ruby. And the reason this is such a game-changer for Bridgetown?

By placing **resource data into signals**, and **transformation steps inside of effects**, we can track via effects which resources or generated pages would need to be updated due to signals changing. In other words, during the initial full build, we're assembling a _dependency graph_ in real-time of which pages should be rebuilt later. That way during a refresh, instead of a simplistic incremental regeneration acting on one piece of source data and leaving that data stale on other parts of the site—or just doing the full rebuild which can take a long time—we can instead only rebuild 5 interdependent pages, or 10 pages, or even 50 pages…but probably not 200! (Plus we also get to skip a lot of other slow code reloading logic and so forth whenever it's simply not necessary…which is the majority of the time!)

### The Devil's in the Details

This process is fairly straightforward if the changed file in question is indeed a resource. We can build up the resource (which could be a page at a URL or it could be a data file) + dependency graph, and simply regenerate those resources. But things get tricky when "generated pages" are involved such as using prototype pages or pagination. For those cases, we need to backtrack to an original resource and re-extract all the necessary data for the generated pages which follow.

All of the places where reactive data can end up are vital to the integrity of the Fast Refresh process. Think of all the contexts where content cohesion is crucial:

* If you **change the name of a person** in `_data/authors.yml`, all of their blog posts should update.
* If you **change the title of a document**, a sidebar with a list of those documents should update whichever pages include that sidebar.
* If you **update a blog post description**, "page 4" in an archive somewhere should update with that new description.

Doing all that is pretty challenging if you have to trace all those dependencies by hand (either under the hood with complex automagical logic, or with specific directives users must understand and maintain themselves…eww!).

**Thankfully…signals to the rescue.** And we're not simply tracking resource<->resource connections, but connections between templates and rendered components. If I update a single component template, but that template is only referenced by one or a few resources (or layouts used by those resources), why should the entire site get rebuilt? Let's just rebuild the resources which directly render that component. Even layouts factor into this: if you edit a layout, only the resources which use that layout will be regenerated.

For the most part, Fast Refresh will require no changes to existing site repos. It'll "just work". But we do have a new mechanism in particular for handling site-wide data which can prove quite interesting. Instead of reaching for `site.data`, reach for `site.signals`. All of the keys will be shortcuts for setting/getting signal values—aka `site.signals.authors` is shorthand for `site.signals.authors_signal.value` and `site.signals.authors.value = ...` is shortchand for `site.signals.authors_signal.value = ...`. This means you can save and access site data throughout various plugins/templates, and any changes made to data files will propagate accordingly during Fast Refresh.

All of this serves to ensure that when you update a file, it's often rebuilt so quickly that by the time you switch from your editor back over to the site in the browser, _it's already been refreshed._ (We also have increased speed overall thanks to revisions to our Rack/Roda integration!) I've been experiencing this rapid round-tripping a lot over the past few weeks, and it's pretty freakin' cool. 😎⚡️


### Escape Hatch

The version of Fast Refresh shipping in Bridgetown 2.0 will be good, but it won't be perfect. There are times it may get tangled up in the web of its own dependencies, or fail to account for a particular type of change, and you'll need to reboot the dev server—or in the worst case, temporarily switch off fast refresh in your config.

**Fast Refresh will get top priority for bug fixes for the forseeable future**, which is one of the reasons we're releasing it switched on by default. We _want_ as many people as possible to test this right out of the gate, so we can fix edge cases as quickly as possible. My own experience has been that even with an occasional hiccup, **the quality of life improvement with the increased refresh speed more than makes up for those annoyances**. Most of the time, _it rocks._

We'll also be shipping a bonus feature: a way for you to hook into Bridgetown's live reload JavaScript process to control what happens for that browser reload. For users of frontend libraries like Swup, htmx, Turbo, etc. which can swap or even morph page DOM as part of navigation, you could use those to pull in the updated HTML for an _even slicker experience_. 😎

### Performance is a Feature Too

One of the goals of Bridgetown 2.0 (and 2.1 and beyond) is to reframe how we look at opportunities to increase framework performance. There's never been a desire among the core team to shave a few ms off of a synthetic benchmark, or to gain paltry bits of performance at the expense of great DX.

But if we can identify clear wins around simplifying code steps, creating modular configurations, streamlining algorithms, and encouraging certain architectures over others so as to improve the performance of both static generation and dynamic routes meaningfully, we're ready to dive in. If you would like to contribute a test site we can use to benchmark Bridgetown 1.x vs 2.x as we fine-tune this release, please get in touch! Our hope is to gradually build up our release QA process to include regression testing…aka a full site build with each new Bridgetown release should be the same or faster, _definitely_ not slower.

OK, that does it for Fast Refresh! **Stay tuned for the next installment of the "Road to Bridgetown 2.0" series** all about where we're going with our **Roda** and **Sequel** integrations. _Spoiler alert:_ Bridgetown 2.0 will completely support Rack-native, fullstack, database-driven application requirements where even your _index_ file can be a dynamic route if you so choose. Have your static website cake _and_ eat your dynamic server too? 🍰 **Yep!** 😁