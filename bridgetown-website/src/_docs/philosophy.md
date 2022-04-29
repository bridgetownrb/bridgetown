---
title: Our Philosophy
order: 30
top_section: Introduction
category: philosophy
---

Every successful open source project has a certain "vibe", those thought patterns and behaviors which ensure meaningful, constant progress forward and the growth of a vibrant developer community. Our project may be relatively young, yet we feel it's important to lead with a set of basic principles what will help guide the project long into the future.

(This page is lengthy, so [feel free to skip over to the next section of documentation](/docs/installation)!)

{{ toc }}

## Core Principles

* **Move fast but try really hard not to break things.** Most developer-focused software projects err on a side…either the side of extreme backwards-compatibility with past versions, or the side of evolving quickly and requiring devs to go through multiple rounds of ["yak shaving"](http://projects.csail.mit.edu/gsb/old-archive/gsb-archive/gsb2000-02-11.html) when upgrading to new versions.

  We hope to strike a thoughtful balance between those two extremes. We don't want to break stuff or change the setup process just for the heck of it. But we also don't want to be constrained by past problematic decisions which reduce the quality of the software. History has proven many times over that open source projects which fail to keep pace with the times and new trends in software eventually wither and die. This is a fate we wish to avoid!

* **Embrace the backpack analogy.** We recognize Bridgetown can't be all things to all people. Bloatware isn't good for anybody. However, we do believe that it's important to provide a curated "backpack" of tools ready to go that can help you build _most websites most of the time_. Like Ruby on Rails' "everything you need" perspective, we want Bridgetown to come with _everything you need_ to get started building great websites.

* **Convention over configuration.** Again, to take a cue from that other popular Ruby-based framework (😉), we strongly believe Bridgetown should encourage powerful defaults and best-practice conventions to give website developments an instant leg up as they start new projects. If you have to go fishing for a bunch of extra plugins and add a slew of extra libraries and reconfigure settings just to complete basic setup tasks, we're doing it wrong.

* **Grow the Ruby ecosystem.** We're unabashed fans of Ruby and consider it our duty to promote and grow the Ruby ecosystem as part of our work on Bridgetown. This includes contributing Ruby code of course, but it also includes developer advocacy and education. Other languages like Go are popular because they're super speedy, or JavaScript because it's, well, JavaScript—but Ruby continues to be a strong contender because [it optimizes for programmer happiness](https://basecamp.com/gettingreal/10.2-optimize-for-happiness). We hope that some day when a Ruby beginner wants to get their feet wet, they'll start by reaching for Bridgetown and writing a custom plugin or two for their website.

* **Be a leader in Jamstack-style technology** (_without being constrained by it_)**.** Bridgetown's progenitor ([Jekyll](https://jekyllrb.com)) played a significant role in kicking off the modern explosion of the "Jamstack" due to its static generation bona fides. In fact, there might not _be_ a Jamstack today if Jekyll's popularity as the technology powering GitHub Pages hadn't caught fire in the early 2010s. Our sincere wish is that Bridgetown would play a unique and vital role in the continued expansion of this exciting way of building and deploying websites, while also identifying and correcting ways we feel the Jamstack space has strayed too far from its inaugural mission. (For instance, we're _skeptical_ of building complex fullstack applications using serverless functions. It's a solution in search of a problem not everyone has, and it's often promoted by the very hosting companies who benefit from increased usage of serverless functions _because they offer no alternative_. Buyer beware!)

## A Brief History of Bridgetown

Bridgetown started life as a fork of the granddaddy of static site generators, [Jekyll](https://jekyllrb.com). Jekyll came to prominence in the early 2010s due to its slick integration with GitHub, powering thousands of websites for developer tools. In the years since it has grown to provide a popular foundation for a wide variety of sites across the web.

But as the concepts of modern static site generation and the "Jamstack" came to the forefront, a whole new generation of tools rose up, like [Hugo](https://gohugo.io), [Eleventy](https://www.11ty.dev), [Next.js](http://nextjs.org), and many more. In the face of all this new competition, Jekyll chose to focus on maintaining extensive backwards-compatibility and a paired-down feature set—noble goals for an open source project generally speaking, but ones that were at odds with meaningful portions of the web developer community.

So in March 2020, Portland-based web studio [Whitefusion](https://www.whitefusion.studio) started on **Bridgetown**, a fork of Jekyll with a brand new set of project goals and a future roadmap. Whitefusion's multi-year experience producing and deploying numerous Jekyll-based websites furnishes a seasoned take on the unique needs of web agencies and their clients. Since that time, we've seen this strategy pay off in a big way.

Bridgetown has grown considerably since its inception, but in many ways, we're just getting started. We hope you [join our community](/community), build something awesome with Bridgetown, and share it with the world!

## Future Project Roadmap

In late 2021, we crafted a new roadmap for our work on Bridgetown's underlying technologies as well as "marketing" focus heading into 2022. Bear in mind many of the plans outlined below are already present and built into Bridgetown v1.0. But to recap:

We are organizing our work around these three tracks:

* The Platform Track
* The Content Authoring Track
* The Experiences Track

### The Platform Track

These are the core architectural features Bridgetown needs to be successful across all site builds and deployments.

Included in this track are:

* Switching the built-in server from WEBrick to Rack + Puma, along with Roda to handle intelligent serving of static assets (more on Roda below).
* Migrating away from relying on `yarn` as the principal CLI tool and standardizing around the `bin/bridgetown` stub + Rake integration. (We'll still use Yarn for installing and bundling frontend dependencies.)
* Putting the finishing touches on a huge effort we’ve been calling “The Great Content Re-alignment” — aka replacing the aging Jekyll-derived content engine with the new Resource engine (which among other things supports conceptual consistency, relationship modeling, and taxonomies).
* Enabling dynamic rendering of specific data and resources within Bridgetown, thus opening the doors to SSR (Server-Side Rendering) and other fascinating use cases.
* Resolving a number of deprecations, alterations, and needed fixes in order to arrive at API stability for 1.0 and beyond.

### The Content Authoring Track

These are features needed to make Bridgetown the perfect choice for advanced content authoring requirements.

* Implementing robust multilingual and localization features (i18n), continuing under-the-hood work we’ve already undertaken.
* Creating integration points and even full gems to provide turn-key solutions for headless CMSes like Prismic and Strapi.
* Adding advanced interactions with file-based content structures and Git state (think `jekyll-compose` on steroids along with WordPress-style status and revision control)…allowing third-parties to build their own Ruby-based “CMS” solutions.
* Providing publishing lifecycle and webhooks so Bridgetown seamlessly fits into a larger editorial pipeline.

### The Experiences Track

These are features _and_ educational resources needed to improve both the DX (Developer Experience) and UX (User Experience) of Bridgetown-based websites and web applications. This is admittedly the most “fuzzy” category, but nevertheless is a vital aspect of our overall mission.

* Launching an entirely new logo/brand and website for Bridgetown to promote the project, showcase real-world usage, provide world-class documentation to developers, and advocate for Ruby as a premier choice for web developers. **_Done…you're looking at it right now!_**
* Promotion of well-produced themes and theme-like plugins which give teams a huge leg up in starting new Bridgetown sites.
* Ensuring Bridgetown defaults, recommended best practices, and officially supported ecosystem tooling are aligned with the latest standards and features of the web platform (high-quality semantic HTML, truly modern framework-less CSS, vanilla JavaScript with optional partial hydration) along with examples of effectively using platform-aligned third-party projects (such as Lit for web components, Hotwire/Turbo for SPA-like navigation and inline updates, etc.).
* Partnering with and supporting other Ruby-based projects which have goals and use-cases that mesh well with Bridgetown and its approach to web development.
* Moving ahead with architectural advances which would allow Bridgetown to facilitate site interactivity through a bona fide backend (aka write your serverless-less code here folks!), powered by the wicked-fast [Roda framework](http://roda.jeremyevans.net). This is the ultimate culmination of the DREAMstack concept (Delightful Ruby Expressing APIs & Markup).
	* Much of the work done for the above will also make Bridgetown + Rails monorepos a legit developer story.
* Along those lines, researching and pioneering new tools and practices around production deployments so we achieve many of the DX and global performance advantages of Jamstack’s “serverless” principles without the many accompanying downsides. Think CDN-like containerization of the backend, static + backend configurations which build and deploy simultaneously, robust connectivity with distributed databases and key-value stores (aka Redis), and other such concerns.
