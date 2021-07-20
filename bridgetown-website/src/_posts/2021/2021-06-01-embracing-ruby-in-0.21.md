---
title: "Embracing Ruby, the Best Language for Building Websites, in Bridgetown 0.21"
subtitle: |
  Support for ViewComponent is finally here, along with numerous advances which fuel high-level design thinking. The powerful combination of Ruby and Bridgetown today enables tiny teams to compete favorably with much larger competitors.
author: jared
category: release
---

<figure style="margin:0 0 2.5em; box-shadow:0px 10px 30px rgba(0,0,0,0.2); border-radius:4px; overflow:hidden"><img src="https://res.cloudinary.com/mariposta/image/upload/c_fill,w_1920,h_1160,q_65/broughton-beach.jpg" alt="Photo Broughton Beach in Portland, Oregon" style="display:block"></figure>

**Bridgetown v0.21 "Broughton Beach" has been released!** 🎉 It's a major leap forward for the project ([just look at those release notes!](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.21.0)), and we're proud of the work we've accomplished to push Bridgetown much closer to its 1.0 milestone. As always, you can upgrade by simply bumping the version in your Gemfile:

```ruby
gem "bridgetown", "~> 0.21"
```

and running `bundle update bridgetown`. In addition, we now have a way to upgrade your Webpack config! Keep reading for further details.

So what's new in Broughton Beach and why do we think Ruby is the best language for building many of today's demanding websites?

{% toc %}

### The Rise of Components

React (along with other frontend libraries/frameworks) has made component architecture front and center in web development. The result is some welcome advances in how we author, test, and deliver web content and functionality…but with it often comes enormous complexity requiring advanced build tooling which often falls apart when you need it the most.

One of the most exciting new ways of thinking about components in the context of server-rendered applications (aka SSR) has been [GitHub's ViewComponent library](https://viewcomponent.org). ViewComponent has been instrumental in modernizing GitHub's massive public-facing app with a view architecture that is at once familiar and forward-thinking. It's increasingly at the heart of many of GitHub's web properties and has revolutionized how many Rails developers approach building UI. Like Rails, it encourages convention-over-configuration and is incredibly easy to get started with.

In Bridgetown 0.21, we're bringing that same ethos to the world of static site generation (SSG). Instead of thinking of your website design as a labyrinthine sequence of templates and partials, you can instead think about it as a _composition _ of _components_ which are encapsulated, repeatable, testable, and distributable. These components are a combination of **real Ruby code**, with all of the **power and flexibility** that affords, plus template files written in your **choice of language** (ERB, Serbea, Haml, Slim, and beyond!). And by combining your SSR/SSG component markup with modern frontend techniques such as web components and design tokens, you can reason about your **frontend CSS and JS code** at the same component level and it all **Just Works**™.

Here's a peak at what this all looks like:

```ruby
# src/_components/field_component.rb
class FieldComponent < Bridgetown::Component
  def initialize(type: "text", name:, label:)
    @type, @name, @label = type, name, label
  end
end
```

```erb
<!-- src/_components/field_component.erb -->
<field-component>
  <label><%= @label %></label>
  <input type="<%= @type %>" name="<%= @name %>" />
</field-component>
```

```erb
<!-- some page template -->
<%= render FieldComponent.new(
      name: "email_address", label: "Email Address"
    ) %>
```

This is enabled by the new `Bridgetown::Component` infrastructure built-into Broughton Beach, which features an API very similar to ViewComponent. We feel this is a great start for many Bridgetown projects. _However_, we didn't stop there. **We brought ViewComponent directly to Bridgetown**. 🤯

Yes, you're reading that right. You can write new components using  `ViewComponent::Base`, and in many cases utilize existing components you've already written. We made this work by instantiating a tiny shim which "fools" ViewComponent into thinking it's loaded inside of a standard Rails application. Because ViewComponent almost entirely relies on Rails' ActionView gem alone, it integrates pretty seamlessly with our own [ERB-and-beyond](/docs/erb-and-beyond) rendering pipeline.

[Check out this example project](https://primerdemo.onrender.com) which showcases GitHub's Primer design system, and [read up on the new component documentation](/docs/components/ruby). We think you're gonna love it.

P. S. **Breaking Change**: In order to provide better compatibility with ViewComponent and the Rails ecosystem, [ERB now uses an output safety buffer](/docs/erb-and-beyond#escaping-and-html-safety){:data-no-swup="true"} to escape HTML in most strings. This means you may need to use `raw/safe` helpers or `html_safe` whereas in previous versions you didn't.

### All-new take on Ruby Front Matter, plus pure-Ruby data files and templates

Bridgetown has long offered a mechanism where you can add a block of Ruby code inside of front matter YAML, but it was a bit awkward, plus it still had a hard dependency on YAML as the only front matter format supported.

No longer! In Broughton Beach, you can write **pure Ruby code** as front matter for any or all of your content and layouts (requires the new Resource content engine to be enabled). Not only that, but you can write resources as Ruby files and this even works with data files (yep, add `.rb` files in `src/_data` FTW!). Why would you want to do this? Because Ruby is amazing at allowing you and others to write **sophisticated DSLs** (Domain-Specific Languages) which can express high-level concepts around data processing and serialization as well as markup generation. The greatly expands Bridgetown's purview from just handling Markdown/HTML content to facilitating a wide range of number-crunching, data analysis, and niche publishing use cases.

When you contemplate what you'll be able to easily accomplish now—especially in the realm of teaching/learning and rapid prototyping—the sky's the limit. [Check out my (Jared)'s blog post on the topic](https://www.ruby3.dev/jamstack-frameworks/2021/05/11/teaching-or-learning-ruby-try-bridgetown/) for more information. Or [read the documentation here](/docs/resources#ruby-front-matter-and-all-ruby-templates){:data-no-swup="true"}.

### Additional progress on the Resource content engine — and this is the LAST release where it's optional

We've made many notable improvements to the Resource content engine in Bridgetown 0.21, including a whole new way of [expressing relations between resources](/docs/resources#resource-relations){:data-no-swup="true"} (one-to-many and many-to-many) for advanced content modeling.

Also be advised **this is the last release** where the Legacy content engine is the default and the new engine is something you opt into. In 0.22 we'll be transitioning to the new engine by default—plus completely overhauling our documentation to reflect that—and you'll need to opt into the legacy engine if necessary. And a release or two later, **we'll officially remove the legacy engine**. More and more sites are currently in development or getting pushed to production using the new engine, and we're confident this is a solid platform to build upon going forward. In case you need a refresher on why the new engine was needed, [here's additional context](/release/back-to-basics-0.20-healy-heights/#the-great-content-realignment-introducing-resources){:data-no-swup="true"}.

### Webpack upgrades are now a piece of cake

Thanks to a tremendous effort by core contributor [Ayush Newatia](https://twitter.com/ayushn21), we now provide a canonical Webpack configuration automatically managed by Bridgetown within your repo and provide a clear integration point to add your customizations (should you need to). [Check out this blog post](https://binarysolo.chapter24.blog/bridgetown-s-new-webpack-cli-tool/) by Ayush to learn more about how you can upgrade your existing Bridgetown sites to the latest Webpack.

Down the road, we anticipate a similar approach to new frontend bundling tools like Snowpack or Vite, as well as adding a flag so you can prevent initial installation of any frontend bundler. Stay tuned.

P. S. We've improved the automation steps to enable [PostCSS](https://postcss.org) or add support for [Tailwind](https://tailwindcss.com), and we've also upgraded our Sass support to the latest [Dart implementation](https://sass-lang.com/dart-sass). Have a favorite frontend CSS or JS library? We'd love to hear about it and perhaps add it to Bridgetown's default list of configurations.

### A note about Jekyll

People are increasingly posting online and asking us (and the Ruby community at large) _what's the deal with_ **Bridgetown vs. Jekyll** and where's it all headed? As Bridgetown has been actively developed (rolling out dozens upon dozens of new features and major improvements) since its initial fork from Jekyll over a year ago, we feel it's time to offer some clarity.

We've tried and have thus far been unsuccessful in encouraging an official public announcement by the Jekyll core team about the future of Jekyll. Which is unfortunate because it perpetuates continued confusion about the status of these two seemingly similar projects. We have enormous respect for the legacy and impact Jekyll has had (it's literally the progenitor of the modern Jamstack movement!), so it's a real shame to see it simply wither on the vine.

Our take is this: **Bridgetown is the future, Jekyll is the past**. The version of Jekyll you can download today is pretty much what Jekyll will be going forward. The exact words from the core team are "[maintenance phase](https://github.com/jekyll/jekyll/issues/8085#issuecomment-606180128)", and regarding a roadmap, "[there isn't one](https://github.com/jekyll/jekyll/issues/8085#issuecomment-606730916)". And those comments are over a year old—predating the genesis of Bridgetown! The situation has gotten even more dire since then, with [the sole remaining Jekyll maintainer who's active on the project](https://github.com/DirtyF) actively promoting competing solutions like [Next.js](https://tina.io/blog/tina-cloud-and-nextjs-the-perfect-match/) and [Hugo](https://jamstatic.fr). Make of that what you will.

Of course we're terribly biased, but **we recommend against starting any new projects using Jekyll**. If for some reason you're looking for something that's _not_ Bridgetown, we recommend taking a look at either [Middleman](https://middlemanapp.com) (also Ruby) or [Eleventy](https://www.11ty.dev) (JavaScript).

In the coming weeks we'll be putting together a detailed migration guide to help you move your existing Jekyll sites to Bridgetown. If you're a Jekyll plugin or theme author, please reach out to us. We'll help you with porting your solution to Bridgetown as well as **showcase it on our upcoming redesigned website** when it launches in Q3 2021. And if you're looking for enterprise-grade Bridgetown consulting services, [there's an increasing number of offerings available](https://github.com/bridgetownrb/bridgetown#commercial-support).

### Conclusion

Time and time again when we ask folks (on Twitter and elsewhere) why they choose Ruby over other languages to build projects with, we hear a constant refrain: Ruby offers **the most expressiveness, power, and high-level design thinking in the industry today**, enabling _tiny teams_ to compete favorably with _much larger competitors_—all while staying **fun and drama-free** (aka minimal [yak shaving](https://americanexpress.io/yak-shaving/) necessary). Also—in case you haven't noticed—[Ruby's gotten fast](https://twitter.com/jaredcwhite/status/1379085963830259716?s=21). And when we ask why a few folks have switched to other languages instead, it's almost always an issue of Ruby being hard to install or not well-supported in some very specific way.

We're on a mission to **solve the latter, while emphasizing the former**. Can Ruby prove to be easy to install and well-supported all while kicking butt in the world of building amazingly sophisticated web software and publications? **We believe so**. That's why we're building and promoting **Ruby + Bridgetown = ❤️** now and will continue doing so well into the next decade.

**[Join our online community](/docs/community), become a contributor, and let's build the world's happiest website development platform together!**
