---
date: Thu, 29 Feb 2024 08:14:56 -0800
title: Road to Bridgetown 2.0, Part 2 (New Baselines)
subtitle: Announcing a solid set of defaults we believe will make Bridgetown that much more robust, appealing, and ready to tackle the challenges of tomorrow.
author: jared
category: future
---

> “And blood-black nothingness began to spin…a system of cells interlinked within cells interlinked within cells interlinked within one stem…and dreadfully distinct against the dark, a tall white fountain played.”
{: style="text-align:center; margin-inline: 1.25vw"}

OK OK, not that [baseline](https://www.youtube.com/watch?v=1h-seEowtDw). 😜

Rather, what we're talking about are **technology baselines**. Minimum language version requirements. Language syntaxes. Tool dependencies. That sort of thing.

The **Bridgetown 2.0** release cycle lets us reset some of these baselines, moving the framework into a more modern era without sacrificing developer experience or causing major upgrade headaches. For the most part, you should be able to keep your projects running with few (if any) changes. But of course, with a little spit and polish, you'll be able to take full advantage of improvements lower in the stack.

Let's step through the various baselines we'll be providing in Bridgetown 2.0.

### Ruby 3.1

Bridgetown 3.1 will require a **minimum Ruby version of 3.1**. Our policy is that for each major version number increment (in this case, v2), we will move the minimum Ruby version to two yearly releases prior to the current one. Since today's Ruby version is 3.3, that allows us to support Ruby 3.1 and 3.2 as well.

Because we're moving from the past minimum of Ruby 2.7 to 3.1, this opens up a whole new world of Ruby v3 syntax and functionality being made available to the Bridgetown ecosystem. I wrote about [some of my favorite Ruby 3.1 features](https://www.fullstackruby.dev/ruby-3-fundamentals/2021/01/06/everything-you-need-to-know-about-destructuring-in-ruby-3/) over two years ago! And even more has happened since with the releases of Ruby 3.2 and 3.3. (YJIT, anyone?)

We suspect many Bridgetown projects are already on Ruby 3, and for those still using Ruby 2.7, the upgrade process to switch to at least 3.1 should be fairly smooth.

### Node 20

Until recently, for a good window of time it seemed like the particular version of Node you happened to be running wasn't a huge deal since Bridgetown's use of Node has been almost exclusively relegated to compiling frontend assets.

While that will continue to be the case, we are making some specific, intentional changes to *how* Bridgetown integrates with Node. In order to streamline these efforts, it makes sense to standardize on newer versions of Node.

As of the time of this writing Node 21 is the current production release, but as we suspect Node 22 is right around the corner (based on Node's yearly release schedule), we are jumping the gun just a tad and going with **Node 20** as our baseline (since essentially that will be two versions prior to current once Bridgetown 2.0 is released later in Q2).

Which brings us to:

### ESM

The JavaScript NPM ecosystem has been stumbling towards its goal of coalescing around ES Modules (ESM), rather than CommonJS, for quite a long time now. It feels like we've arrived at the moment when it's now or never, so let's do it now. For those of you only vaguely aware of what the differences are, here it is in a nutshell:

```js
const path = require("path") // CommonJS

import path from "path" // ESM
```

Yes, for those of you asking, ESM has been the _only_ way you write JavaScript for client-side purposes (since ES6 anyway). Yet Node's historical CommonJS manner of importing and exporting modules and packages has persisted on the server. The end is nigh though, as universal ESM syntax has been embraced more and more throughout the ecosystem.

There are two ways to instruct Node to use ESM instead of CommonJS. You can name JavaScript file extensions as `.mjs`. Or you can add `"type": "module"` to your `package.json` file.

For Bridgetown 2.0, **we will be opting for that latter option**, and all configuration files for tools like esbuild and PostCSS will be supplied in ESM format. CommonJS will still work in your existing projects, but for all new projects, it will be all ESM, all the time! 👏

### Farewell Yarn

When the Bridgetown framework first launched in 2020, many people considered Yarn to be a better package manager than Node's built-in `npm` solution. Many frameworks had built up around it, and even Ruby on Rails had embraced it.

But time doesn't stand still, and neither did npm because at this point, it works just as well as "classic" Yarn and newer versions of Yarn ended up causing headaches due to changing designs, syntax, and feature-set sweet spots.

So in Bridgetown 2.0, we're greatly simplifying and **migrating to using npm by default**. You still have the *option* of keeping classic Yarn around for use in your existing Bridgetown projects—or you can switch over to npm or even another popular package manager, [pnpm](https://pnpm.io/). We'll focus on npm out of the box, but switching to pnpm should you wish it will be straightforward (we've actually supported it in the most recent v1.x releases anyway).

### Farewell Webpack

Bridgetown has defaulted to using esbuild for its frontend bundler for some time now, but with Bridgetown 2.0 **we'll be removing official support for Webpack**. This does mean we recommend migrating your projects from Webpack over to esbuild *as soon as possible*, since we have no guarantee Webpack will continue to work once Bridgetown 2.0 arrives.

The writing has been on the wall for some time, as the entire web industry generally pivots away from Webpack and towards more modern solutions like esbuild (Vite, Turbopack, and Parcel being some other popular options).

The good news is that we continue to feel *extremely* satisfied with our embrace of esbuild. I personally like to say that esbuild is the "last bundler" I'll ever use. And I really believe that. I see no reason years from now why esbuild won't still be perfectly adequate to perform the sorts of lightweight frontend bundling and asset pipeline tasks Bridgetown users typically require. It's nice to have that level of confidence in a framework dependency.

### ERB by Default

And last but certainly not least, we'll be switching away from Liquid as our default out-of-the-box template engine and over to ERB. Bridgetown is a Ruby framework after all, and **ERB is the template language most Rubyists are familiar with**. The reason we ever defaulted to Liquid in the first place was an historical one…Jekyll defaulted to Liquid—and in fact _only_ supports Liquid (you have to install a third-party plugin to get some sort of ERB support). But with Bridgetown having supported ERB for years now, it makes sense to go ERB-first.

However, we have a few tricks up our sleeve—some extra features in the works to bring [Serbea-like pipelines over to ERB](https://www.serbea.dev/#add-pipelines-to-any-ruby-templates), as well as a new DSL based on procs & heredocs called **Streamlined** you can use instead of ERB in certain parts of your codebase to generate complicated HTML quickly and efficiently. (This is essentially our answer to "tag builders.")

And for that **maximum cool factor**, we'll be unveiling an optional, first-party solution to server-rendering **web components** which can later be hydrated and become interactive on the client-side. We've already offered a solution of sorts along these lines with our [integration of Lit-based web components](https://www.bridgetownrb.com/docs/components/lit). However, this new solution will provide a whole new component format—one which takes further advantage of Ruby as well as the proposed [HTML Modules](https://github.com/WICG/webcomponents/blob/gh-pages/proposals/html-modules-explainer.md) spec. *Ooo…exciting!*

(Note that we'll be retiring first-party support for Haml and Slim. I don't wish to step on anybody's toes, but template syntaxes based around indentation/whitespace rules just aren't on the radar of frontend developers by and large. I would argue they feel more like an artifact of Ruby's past than anything modern developers are looking for. Let's rally around writing HTML templates in ways which frontend devs can feel comfortable with and get up to speed on quickly.)

### Wrap Up

So there you have it: **Ruby 3.1. Node 20. npm. esbuild. ERB and a whole lot more.** A solid set of defaults we believe will make Bridgetown that much more robust, appealing, and ready to tackle the challenges of tomorrow.

There are also some efforts underway to streamline parts of Bridgetown's internals to make it easier for contributors and maintainers. Besides simply removing a handful of small deprecations, we're in the process of completely moving away from Cucumber and towards standard Minitest for integration tests to bring them in line with the rest of the automated test suite. You can [read more about these efforts](https://community.bridgetown.pub/post/10) on the community site.

Along with quality-of-life and maintenance improvements, we hope to make progress in increasing the build performance of Bridgetown. Perhaps not so much in production per se (where, to be honest, it's less critical—the difference in your site rebuilding in CI in 12 seconds vs. 6 actually doesn't matter much), *but most definitely in development*. We all know how frustrating it can be to make a small text change and then have to wait seconds—maybe even tens of seconds!—before the page will refresh in your browser. We have a solution in mind called **Fast Refresh** based on the principles of Signals, using the [Signalize gem](https://github.com/whitefusionhq/signalize) which is a Ruby port of Preact Signals. It's not quite an "incremental build" type of solution, but it'll get us where we need to go. More on all that in the next installment of *Road to Bridgetown 2.0*.

Until then, [hop on over to our community site and let us know](https://community.bridgetown.pub/post/12) what you're most excited about regarding these changes in Bridgetown 2.0. As always, your feedback is most welcome!
