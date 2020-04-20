---
title: It's Time to Visit Bridgetown
subtitle: Your favorite static site generator, reimagined for the modern Jamstack era.
author: jared
---

{:.has-text-centered}
_I almost titled this first post [Holy Mother Forking Shirt Balls!](https://www.youtube.com/watch?v=qltrjYI2vHk), but cooler heads prevailed._{:.is-size-7} 😆

{:.mt-10}
So, introducing **Bridgetown**. What is it?

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
It's a static site generator.

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
Yes, like [Jekyll](https://jekyllrb.com).

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
In fact…

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
…the reason it's a lot like Jekyll is because…

{:.has-text-weight-medium.is-size-5.mt-10.mb-8}
…it _is_ Jekyll. (Well, kind of.)

**Let me explain.** Or rather, let our [About page](/about/) do the talking:

{:.my-12}
> Bridgetown started life as a fork of the granddaddy of static site generators, [Jekyll](https://jekyllrb.com). Jekyll came to prominence in the early 2010s due to its slick integration with GitHub, powering thousands of websites for developer tools. In the years since it has grown to provide a popular foundation for a wide variety of sites across the web.
> 
> But as the concepts of modern static site generation and the [Jamstack](/docs/jamstack/) came to the forefront, a whole new generation of tools rose up, like [Hugo](https://gohugo.io), [Eleventy](https://www.11ty.dev), [Gatsby](http://gatsbyjs.org), and many more. In the face of all this new competition, Jekyll chose to focus on maintaining extensive backwards-compatibility and a paired-down feature set—noble goals for an open source project generally speaking, but ones that were at odds with meaningful portions of the web developer community.
> 
> So in March 2020, Portland-based web studio [Whitefusion](https://whitefusion.io) started on **Bridgetown**, a fork of Jekyll with a brand new set of project goals and a future roadmap. Whitefusion's multi-year experience producing and deploying numerous Jekyll-based websites furnishes a seasoned take on the unique needs of web agencies and their clients.

That's a fairly long-winded way of saying: I ([Jared](https://github.com/jaredcwhite)) have been building a plethora of advanced websites with Jekyll for quite a while now—yet as much as I have loved working with it, it's definitely started to show its age. After an amicable conversation with the Jekyll core team, I decided to take on the exciting (but incredibly daunting!) task of ["forking"](https://en.wikipedia.org/wiki/Fork_(software_development)) Jekyll and using it as the starting point for a _reimagined_ Ruby-based website framework: **Bridgetown**. And not just me, but I'm betting the entire future of my web studio [Whitefusion](https://whitefusion.io) on this technology.

### Already Going Places

In [a short amount of time](/about/#roadmap), Bridgetown has introduced a slew of new features, cleaned out deprecated or confusing configuration options, and laid the groundwork for major improvements to the manner in which static sites get built for Rubyists and beyond. Our premise is simple: we don't just want Bridgetown to be a good Ruby-based tool for generating sites. **We want it to be good, period.**

That's why all these changes being made to the codebase now, while perhaps painful in the short term for anyone wanting to quickly migrate from Jekyll to Bridgetown, are vital and necessary, because **we're planning for the next ten years of [Jamstack](/docs/jamstack) technology innovation**.

This includes our **[whole-hearted embrace of Webpack](/docs/frontend-assets/)**. Webpack (and similar Javascript tools like it) has in fairly short order become absolutely indispensable to modern frontend web development—to the point that I would argue any website framework which _doesn't_ use a tool like Webpack to manage frontend dependencies (along with NPM/Yarn) is _actively harming_ its developer community.

Part of the reason people turn to software frameworks to build things is to get **good defaults**. You want something that comes with [everything you need](https://rubyonrails.org/everything-you-need/) to start off right so you don't have to reinvent the wheel or get lost in an industry dead end. This is an active and ongoing focus for Bridgetown, from how the software gets installed, to configuring typical settings and plugins, to best practices in building and deploying the final site.

### Bridgetown, Not "Crazytown"

In the year 2020, as the Jamstack phenomenon has taken off like a rocket along with all the ways the web community is pushing the tech forward, a sane person might  argue that it's time to give up using a Ruby-based framework entirely and switch to using Eleventy, or Gatsby, or Hugo, or Next.js, or Nuxt, or…the list goes on. Listen, I get that, I really do! [There are already too many static site generators out there.](https://www.staticgen.com)

But I’m crazy enough to believe in the bones of the Jekyll software and essential stack choices: Ruby as a delightful, productive language; the power of Liquid templates for rapid layout and prototyping ([and soon components!](https://github.com/bridgetownrb/liquid-component)); Kramdown with all its awesome enhancements to Markdown; Gem-based plugins, convention over configuration, etc.). In fact, having now read through every code file and test in the process of making substantial changes and adding new features to Bridgetown, the strength of this technology stack is clearer to me than ever before.

**Today, this has become a reality:**

0. `gem install bridgetown -N`

0. `bridgetown new amazing_website`

0. `cd amazing_website && bundle install && yarn install`

0. Terminal 1: `yarn dev` Terminal 2: `bundle exec bridgetown serve`

And instantly you have a forward-looking, functioning website foundation _with full Webpack support_ for adding CSS frameworks like Tailwind and Bulma, Javascript frameworks like Stimulus, Vue, or React, and virtually any module on NPM.

_And you don't have to abandon Ruby to do it._

Get started today.
{:.has-text-weight-medium.is-size-5.has-text-centered.my-10}

[Go Bridgetown](/docs/){:.button.is-large.is-warning.is-outlined}
{:.has-text-centered.my-10}

(or [find out how you can become a contributor](/docs/community/)…or perhaps join the Bridgetown core team!)
{:.has-text-centered}

{% rendercontent "docs/note", extra_margin: true %}
P. S. Let us know if you plan to build something awesome with Bridgetown! And be sure to use the hashtag [**#SpinUpBridgetown**](https://twitter.com/intent/tweet?url=https%3A%2F%2Fbridgetownrb.com&via=bridgetownrb&text=Check%20out%20this%20awesome%20new%20static%20site%20generator%20built%20in%20Ruby%21&hashtags=SpinUpBridgetown%2CJamstack) and spread the word! 😃
{% endrendercontent %}
