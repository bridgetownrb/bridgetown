---
title: "Progress Report: Bridgetown is Now esbuild-Aware"
subtitle: We put a stake in the ground at the very beginning of the Bridgetown project that we'd embrace frontend developers via first-party Webpack integration. Now it's time to move on and embrace the speed and flexibilty of esbuild.
author: jared
category: feature
---

As the winter holiday season kicks into high gear (for us Northern Hemisphere folk), it's time for a progress report on Bridgetown's path to 1.0 vis-à-vis the [fundraising effort](https://fundraising.bridgetownrb.com).

As of the writing of this post, we've raised **$2,843** out of a **$5,000** goal. That means we're still hoping to raise at least $2,157. We don't have an "end date" set yet, but ideally we're getting _real close_ by the end of January.

Now let's look at developer time spend so far:

* Work on improvements across the Bridgetown ecosystem and release alpha6: **1.75**
* Zeitwerk autoload paths: **3.0**
* Continue work on Zeitwerk PR: **2.0**
* Finish up Zeitwerk PR: **1.5**
* Address feedback on Zeitwerk configuration: **0.75**
* Fix weird Ruby 2.7/3.0 compatibility issues with alpha7 and release alpha8: **4.25**
* Serbea documentation: **0.75**
* Improving documentation and preparing for alpha9 release: **2.0**
* Fix descendants and Zeitwerk reload bug, release alpha10: **1.5**
* Add roundtrip saving of repo models: **1.5**
* Refactor hooks (particularly for SSR) and the watcher, update documentation: **2.5**
* Fix production ENV issue with Roda file-based routes: **0.5**
* Deep work for esbuild integration: **5.0** 👀
* Begin official esbuild branch for setup/config: **2.25**
* Get alpha11 release ready: **2.0**
* Clean up listener/watcher: **0.5**
* **TOTAL: 31.75**

Developer time has slightly outpaced fundraising at this point, but that's not unexpected. We also elected to pass $500 on to a very talented designer who is working on a new offical logo and style guide for Bridgetown. More to be announced soon!

There's also been a flurry of effort not included in this direct report to further ecosystem enhancements (plugins, methodologies, etc.) which tie into the overall 1.0 launch, such as our [Prismic CMS plugin](https://github.com/bridgetownrb/bridgetown-prismic), [CableCar/mrujs integration](https://github.com/bridgetownrb/bridgetown/pull/465), and seamless support for ActiveRecord (yes, [that ActiveRecord!](https://guides.rubyonrails.org/active_record_basics.html)) & databases.

## So, about that "esbuild" line item…

First, a little history lesson…

We put a stake in the ground at the very beginning of the Bridgetown project that we'd embrace frontend developers via first-party Webpack integration. This move wasn't without controversy at the time, and still garners strong feelings.

Some people just want their static site generators to only deal with HTML output and various related files. Whatever frontend-specific needs people have should be a separate, non-core concern.

I completely reject that philosophy. Virtually nobody is designing a professional website in the year 2021 (2022!) which doesn't have sophisticated CSS needs, and often JavaScript as well. Proper support for the NPM ecosystem isn't a "nice-to-have". **It's table stakes.**

Other people think the right solution is to offer various "starter kits" so you can pick your frontend "flavor" of choice. So the core framework just handles A->B static transformations, and frontend bundling is simply a recommended (and hopefully supported) add-on.

I also reject this philosophy. Bridgetown has always been intended to be an opinionated, soup-to-nuts framework. Just like Rails. Just like Next.js. I'm on record as not liking starter kits (aka _download this random repo off of somebody's GitHub and just use that…_). **I think frameworks should be able to support whatever obvious project configurations you need out-of-the-box whenever you run the `new` command.** Automations and plugins should enhance your projects in repeatable, testable ways. **You will never see me author, nor recommend starter kits.** Bridgetown will always encourage you to run `new`, `apply` or `bundle add`. That's it.

Given all that, we designed our Webpack integration to be set-and-forget. Our out-of-the-box `webpack.config.js` file has _virtually nothing in it_. It simply inherits a strong set of defaults—defaults which are maintained and sometimes upgraded by the Bridgetown core team but are checked into your repo for close examination should you wish to.

**It's a pretty sweet setup.** And, personally, I rather like Webpack. It hasn't been a horror show for me by any means.

But not everyone feels this way. Webpack has caused much consternation in various fullstack communities over the years. It can get slow and fiddly. It brings with it a large dependency graph. Heavy-duty transpilers like Babel are needed less and less as everyone adopts modern evergreen browsers. Rails and Phoenix are shifting greenfield thinking away from it. Even some big-name frontend frameworks are regrouping around other tooling like Vite or Snowpack. In all cases, a particular lower-level bundler keeps inserting itself into the conversation, and that's **[esbuild](https://esbuild.github.io)**.

esbuild is an _extremely fast_ JavaScript bundler, written in Go but with support for JavaScript build plugins. Because esbuild sits at a relatively low level in any frontend toolchain, it has become the basis for higher-level abstractions. esbuild doesn't itself claim to solve all your frontend bundling needs, but instead provides a performant, tightly-focused baseplate upon which to build your tooling.

Herein lies a particular dilema. In order for Bridgetown to adopt esbuild for its ultimate speed, minimal footprint, and flexibility—all while keeping the DX (Developer Experience) on par with our Webpack integration—we couldn't just add a basic command to kick off esbuild and call it a day. We needed _an opinionated set of defaults_…a true out-of-the-box configuration…so you could still do `bridgetown new` and get a solid experience right away, but also be afforded the option to jump headfirst into customizations in an officially supported way.

**So that's exactly what we did.**

[In this WIP PR](https://github.com/bridgetownrb/bridgetown/pull/461), esbuild is now as tightly integrated into Bridgetown as Webpack. This includes a sidecar watch process whenever you run `start`, deployment scripts (to minify output), an upgradable default configuration, support for common use cases like PostCSS, Turbo, Lit, Shoelace, CableReady, soon Ruby2JS, etc. The works.

In fact, we're so confident in our ability to iterate rapidly on this integration and make it sizzle, **we've decided to make esbuild the default frontend bundler.**

Webpack will continue to be available _and_ supported. But with the release of Bridgetown 1.0, we're all in on esbuild—and PostCSS as well. We believe this is the right path forward for frontend bundling—not just for Bridgetown but for web frameworks across our industry.

## FAQ: Vite? Import maps? Migration strategy?

Three answers to likely questions before I close:

**Q: Why not just adopt Vite or another high-level frontend toolchain?** **A:** We care deeply about two things on the Bridgetown project: taking on _only_ as much frontend complexity as you truly need, and controlling the core stack and DX as much as possible. As mentioned above, frontend bundling is core to to the Bridgetown story. We want to move _further_ into owning that part of the stack, not hand off more to non-Ruby-oriented, third-party tooling. Vite, etc. are great projects. But we're building our own. And esbuild is the way to get there.

**Q: Why not just use import maps? Rails 7 is doing it!** **A:** Pre-dating Webpacker, Rails has featured a built-in Ruby-based frontend bundler called Sprockets. It never left! All import maps do is provide a way to import _third-party_ JavaScript libraries via CDN URLs, and integrate that into a Sprockets-based pipeline. If that floats your boat, fine by me, but I envision a world of hurt coming along with that approach as soon as someone deviates even _slightly_ from the Rails/DHH happy path. Otherwise, Rails 7's `jsbundling-rails` gem pushes things along a bit with actual support for esbuild (as well as a simple interface to Webpack or Rollup if you prefer). However, three problems (!): it's still intended to be Step 1 before you hand everything over to Sprockets. And the esbuild integration is…virtually nothing. It's nothing more than command line invocation. Need to customize esbuild in any way? Add plugins? You're on your own, and apparently that's not a bug, it's a feature. esbuild also lives in a different world than PostCSS, which can be used courtesy of a separate gem (`cssbundling-rails`). Not a fan of that approach to be quite honest, and it's not in keeping with the Rails Doctrine of Convention Over Configuration. Bridgetown will support PostCSS and esbuild working in harmony out-of-the-box…a surprising amount of effort to achieve!

**Q: Well this all sounds cool. How do I upgrade my existing site?** **A:** Well, glad you asked! We'll be providing a `migrate-from-webpack` command to help transition your site from Webpack to esbuild, assuming it was created with a recent version of Bridgetown, and it's using PostCSS. We haven't added a native Sass option to esbuild yet, and that's unlikely to change prior to our first release. Our overall philosophy around Sass is that it's a legacy technology. PostCSS represents the future of stylesheet authoring and that's where our default config and primary focus will lie going forward.

Stay tuned for examples, documentation, and all that good stuff as we get closer to the PR merge and Bridgetown 1.0 Beta 1. In the meantime, if you haven't tried out anything in the latest alpha, [we encourage you to do so](https://edge.bridgetownrb.com)! Feedback and bug reports are most welcome in this crucial time.

Also, if you haven't already, [please contribute to our fundraising efforts!](https://fundraising.bridgetownrb.com) Your direct support is what enables this technology to flourish and further the goals of Ruby web developers everywhere. Cheers!