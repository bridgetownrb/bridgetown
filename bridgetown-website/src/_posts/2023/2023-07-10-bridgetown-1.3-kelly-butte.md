---
title: Presenting Islands Architecture in Bridgetown 1.3 “Kelly Butte”
subtitle: "Also introducing support for Declarative Shadow DOM, much nicer error handling, and many maintenance fixes."
author: jared
category: release
template_engine: none
---

We're pleased to announce the release of **Bridgetown 1.3 "Kelly Butte"**. Thanks to the many contributors who have helped make this release possible!

Read the [release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v1.3.0) or [installation instructions](/docs/installation), or to upgrade from a previous version, simply bump up the version numbers in your `Gemfile` and run:

```sh
$ bundle update bridgetown

# or

$ bundle update bridgetown bridgetown-routes
```

It's not mandatory that you update your esbuild config, but it's definitely encouraged (especially if you'd like to take advantage of the latest experimental frontend features). To do so, run `bin/bridgetown esbuild` to get the latest default configuration and follow the instructions. Some of the changes required a fair bit of tinkering, so if you run into any problems [please let us know](/community) so we can correct them right away.

Here's a rundown of some of the fixes and improvements before we get to the "flashy" new frontend-themed features:

* We've _finally_ upgraded our Faraday dependency to v2. 😅 Puma has well has been upgraded to v6.
* Also the included connection helpers in the Builder API has been much improved.
* Error handling and messaging is _much_ nicer now! Before, certain errors would simply crash the Bridgetown dev process, and if you were viewing your website as that happened, you might not even notice there was a problem. Now, we try to surface error messages right on the website, and the dev process is also less likely to crash. Please let us know if you continue to encounter any severe issues!
* We've added support for Nokolexbor as a faster alternative to Nokogiri for processing HTML Inspectors.
* The `l` helper is now available alongside the `t` helper for localizing dates and other such strings.
* The Lit and Ruby2JS bundled configurations have seen relevant updates.

Now on to the good stuff. ;-P

### Introducing Islands Architecture

**Old and busted:** putting all your JavaScript, web components, and other frontend libraries in a single bundle that applies to every page on your website.  
**New hotness:** only bundling the bare minimum (if anything) for your website as a whole, and instead using "islands" on individual pages as needed.

[As it says in the documentation](/docs/islands), the term [Islands Architecture](https://jasonformat.com/islands-architecture) was coined a few years ago by frontend architect Katie Sylor-Miller and further popularized by Preact creator Jason Miller. It describes a way of architecting website frontends around independent component trees, all rendered server-side initially as HTML but then "hydrated" on the frontend independently of one another.  

Now in Bridgetown 1.3, **we're bringing islands architecture to you** with a seamless integration between our [view components](/docs/components) and our [esbuild frontend bundling system](/docs/frontend-assets). And for even more flexibility, you can even orient your Roda routes around "islands" for a truly modular, full-stack approach to web development.

This is an early step forward for the framework, so your [feedback is crucial](/community) as we increasingly align our best practices with the latest improvements across the industry.

### Declarative Shadow DOM

As it so happens, islands architecture plays very nicely with an experimental new frontend feature we're super excited about: [Declarative Shadow DOM](/docs/content/dsd). You can use DSD in your [layouts](/docs/layouts), [components](/docs/components), and generally anywhere it would be beneficial to increase the separation between presentation logic & content and work with advanced scoped styling APIs. And of course, paired with islands architecture, you can essentially get "hydrated" components that are first server-rendered and then become interactive on the client-side for "free" using native browser APIs—but only when and where needed for optimal performance. Wow!

We're considering these features "experimental" for now, but rest assured, we fully expect they will become mainstays of Bridgetown websites and application architectures in the coming months and years. We can't wait to see what you come up with!

### More Frequent but Smaller Releases

I personally have found it a bit challenging to stay on a steady release schedule this year, and I think it all stems from my reluctance to bundle "mere" fixes and tweaks into a release that doesn't offer a marquee feature to promote. That's my bad, and henceforth I plan to correct it. So starting now, expect to see Bridgetown 1.3.1, 1.3.2, etc. in a more rapid succession, and possibly even 1.4 that's mostly about minor improvements.

We'll never match the release pace of some of our (ahem) JavaScript-based compatriots in the framework space, but we can do better than we have. I also intend to focus more effort on providing improved guidance for new contributors and even new core team members to hop aboard the project and make a meaningful impact.

As always, if you run into any issues trying out Bridgetown [please hop into our community channels](/community) and let us know how we can help. If you're new to Ruby, we're happy to recommend other resources and communities which can give you a leg up. Cheers!