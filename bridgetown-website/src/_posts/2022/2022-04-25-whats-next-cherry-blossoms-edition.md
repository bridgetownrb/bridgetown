---
title: What’s Next for Bridgetown, Cherry Blossoms 2022 Edition
subtitle: Now that we’ve had a bit of time to breathe and get fully settled into v1.0, there is a myriad of enhancements and fixes we’re looking to pull together for the next point release. Here's a sneak peek.
author: jared
category: future
---

<figure style="margin-inline:-0.5rem; margin-block:0 2.2rem;">
  <img src="/images/spring-blossoms.jpg" alt="Spring Cherry Blossoms in Beaverton, Oregon" style="box-shadow:0px 10px 30px rgba(0,0,0,0.2); border-radius:4px; display:block; margin-block-end:0.5rem">
  <figcaption style="text-align:center; opacity:0.5; padding:0.25rem">Springtime Blossoms in Cedar Hills Park</figcaption>
</figure>

The flowers are blooming, the brooks are bubbling, the birds are, um, twittering…tweeting…wait are we still allowed to use those words outside of the social network?!

At any rate, spring is in full swing here in Portland and so is work on the next version of Bridgetown! Not only that, but progress is being made on several fronts in the overall Bridgetown ecosystem.

Let’s take a sneak peek at what’s coming next:

### Bridgetown 1.1

Now that we’ve had a bit of time to breathe and get fully settled into v1.0, there is a myriad of enhancements and fixes we’re looking to pull together for the next point release. Probably the “flashiest” feature on this list is i18n, which stands for **Internationalization**.

Bridgetown 1.1 will offer a simple and predictable way to set up multiple “locales” for a single website. Think resources like marketing pages, blog posts, educational content, products, and more all publishing to URLs such as `/en-US/products/92781-fancy widget` or `/es/docs/usage` or `/zh/articles/next-level` without having to manually place any source files in locale-specific folders. The way this will work is two-fold:

For some resources, you’ll create one for each locale. So you might have `next-level.en.md`, `next-level.es.md`, `next-level.fr.md` all living right next to each other. Bridgetown will provide the necessary helpers so you can cross-reference the “same” resource in each locale.

In other cases, you might want just one single file to get published out to all the locales. Simply create a “multi-locale” resource and you can then embed both conditional and “global” content within the file. This approach also works in templates/partials/components. By checking the value of `site.locale`, you’ll know which locale is currently being rendered out.

Also, through use of the `I18n.t` helper combined with locale-specific YAML files, you’ll be able to store and reuse translated content strings as well. (If this part sounds very similar to Rails…well, it is! We’re using the exact same `i18n` Ruby gem.)

All of these i18n features will also be integrated into pagination and archives (via prototype pages), so you’ll be listing only the available content in the currently selected locale/language.

We’ll have more examples and documentation ready to roll when this gets released. We hope it will provide a solid foundation upon which to build global content reaching a wide variety of audiences!

Other features slated for v1.1 include more bundled configurations for popular frontend packages such as Lit, Shoelace, Ruby2JS, and Open Props; additional tightening up of our Roda integration for dynamic routes/SSR; and seamless Sass support for esbuild (it’s currently only supported still with Webpack).

### ActiveRecord Plugin

Concordantly ([ergo, vis-à-vis](https://www.youtube.com/watch?v=qauCP9qzRrQ)) with the release of Bridgetown 1.1, we will be releasing an official plugin to provide [ActiveRecord](https://api.rubyonrails.org/files/activerecord/README_rdoc.html) support within Bridgetown.

Why, you may ask, would you need to access a database from a Bridgetown site?

**In fact, why not?**

Just because you’re using a static site generator doesn’t mean you should be banned from accessing a database. If you already have a Rails app or other means of creating and managing data, being able to access that same database directly from Bridgetown during the build process means you don’t need to go to the extra trouble of building a REST API or something to that effect for data transfer within Bridgetown. Rather you could stick some ActiveRecord models right into your repo, pull stuff right out of the database, and you’re golden!

Not to mention since Bridgetown also has full dynamic routing/SSR abilities thanks to its Roda integration, once you add ActiveRecord you can do all sorts of fun things like build user signups and handle online payments and process form submissions…the list goes on and on!

Our ActiveRecord plugin will provide full support for generating database schemas and running migrations courtesy of the [standalone_migrations](https://github.com/thuss/standalone-migrations) gem, and it will also save up-to-date schema information in comment blocks at the top of models courtesy of the [annotate_models](https://github.com/ctran/annotate_models) gem. Plus hot reloading via Zeitwerk (including Concerns), along with the expected YAML DB config which seamlessly maps to Bridgetown development, test, and production environments…well, it’s exactly the streamlined DX you’d expect.

Over time we anticipate this becoming the most productive ActiveRecord integration outside of Rails itself, and it’ll likely give many integrated database solutions in other non-Ruby SSGs and web frameworks a run for their money.

### Auth + Auth

Building on top of ActiveRecord support, we’re working on a simple auth + auth solution—aka authentication paired with authorization. Authentication is verifying a known user can log in and stay logged in, and authorization is making sure the user only has access to what you allow (aka only admins should be able to access admin areas, etc.)

For authentication, we’re making use of Rails’ `has_secure_password` feature combined with Roda’s secure encrypted cookie-based `session` plugin. It will intentionally be barebones: email/password and that’s it. We will likely refrain from tackling OAuth, SSO, or any other advanced auth scheme any time in the near future. This is for people who literally just need a simple email/password signup feature. Which in this humble author’s opinion is perfectly fine for most general public websites.

For authorization, we’re making use of [Pundit](https://github.com/varvet/pundit). Pundit provides a straightforward, object-oriented policy subsystem which is easy to use anywhere in your application. Simply create policies to match with the ActiveRecord models and use those to determine things like “can X type of user view or edit Y type of content?”

Auth can become very complicated, and security pitfalls abound, so our hope is provide this totally-optional plugin which offers an “MVP” level of auth for those with simple needs. It will be marked as beta initially in order to become confident over time the solution is robust and (reasonably) secure.

### Paywalls

Naturally, once you have database support and auth, the next obvious problem domain to tackle is the **paywall**. Picture this: you have content—some you want free, and some you want to be presented only to users who are signed in and paid up. Our paywall plugin will provide a clear mechanism and example code for placing a wall around paid-only content.

Our recommended approach will be to keep all resources (and URLs) public, but then place a portion of a resource behind the paywall. This is how most publications do it. You display the first paragraph, or a quick sample video, or something to that effect if the user isn’t signed in. Then once they sign in, everything shows up automatically.

Note that we won’t be implementing the payment side of things for the time being. Thankfully there’s a well-documented Stripe Ruby API for that! Once you’ve confirmed a new subscription, just update the paid status of the user account and watch that paywall come down.

We’re enthusiastic supporters of content subscriptions and utilize them ourselves. We can’t wait to see how people use Bridgetown to publish their own subscription-based content.

### Bridgetown Bash During RailsConf

**Quick aside:** we'll be hosting a little evening get-together for friends of Bridgetown during [RailsConf](https://railsconf.org) week in Portland, Oregon. Space will be limited so be sure to follow [@bridgetownrb](https://twitter.com/bridgetownrb) on Twitter and keep a sharp lookout for an RSVP link!

### The Road Ahead

As you can see, we have quite a full plate of features to look forward to as the year progresses…and we haven’t even mentioned other potential items on the roadmap from form handling to image asset processing. Bottom line: development on Bridgetown continues apace, and we’re excited to get these features out to the community. If you’d like to aid in that effort through contributing code, documentation, tutorials, and the like, [please join our community](/community) and help push the ecosystem of Ruby web development forward.