---
title: Midsummer 2020 Bridgetown Plugin Roundup
subtitle: Bridgetown is amazingly useful right out of the box, but add a few plugins and an automation or two, and it sizzles!
author: jared
category: showcase
---

Over the past several months, Bridgetown enthusiasts and open source software developers have been writing plugins and automations to deck out your website with all sorts of new features and enhancements. I thought it was high time we highlight just a few of these in case you missed them previously. **Let's go!**

### Graphtown

This one's hot off the press! With [the Graphtown plugin](https://github.com/whitefusionhq/graphtown){:rel="noopener"}, you can easily consume GraphQL APIs for your Bridgetown website using a tidy Builder DSL (Domain-Specific Language) on top of the Graphlient gem. There are many use cases for this, but one popular one will be to pull content right out of a headless CMS such as [Strapi](https://strapi.io/){:rel="noopener"}.

Here's how easy that is!

```ruby
# plugins/builders/strapi_posts.rb

class StrapiPosts < SiteBuilder
  graphql :posts do
    query {
      posts {
        id
        title
        description
        body
        createdAt
      }
    }
  end

  def build
    queries.posts.each do |post|
      slug = Bridgetown::Utils.slugify(post.title)
      doc "#{slug}.md" do
        layout "post"
        date post.created_at
        front_matter post.to_h
        content post.body
      end
    end
  end
end
```

With just a few lines of code, you're ready to incorporate the very latest content from your CMS every time you rebuild your site.

### Bridgetown + Stimulus = 😍

[Stimulus](https://stimulusjs.org/){:rel="noopener"} is "a modest JavaScript framework for the HTML you already have." It makes it super easy to add modular, reusable, and composable behaviors and interactions to your site—all without needing to load in a heavyweight solution such as React or Vue.

Now with [the bridgetown-automation-stimulus package by Konnor Rogers](https://github.com/ParamagicDev/bridgetown-automation-stimulus){:rel="noopener"}, you can install Stimulus on your Bridgetown website with a single command! Simply open up your Terminal and run:

```sh
bundle exec bridgetown apply https://github.com/ParamagicDev/bridgetown-automation-stimulus
```

It will create a `frontend/javascript/controllers` folder for you automatically. Simply write your Stimulus controllers there, reference them with `data-controller` attributes in your HTML where needed, and you're off to the races!

### Inline SVG Plugin

SVG images have finally gone mainstream on the web due to their small file sizes, infinite vector scalability, and incredible live customization possibilities via CSS styling.

There's no easier way to embed SVG images directly in your Bridgetown website than using [the bridgetown-inline-svg plugin by Andrew Mason](https://github.com/andrewmcodes/bridgetown-inline-svg){:rel="noopener"}. In fact, we use it right here on the Bridgetownrb.com site to embed our logo on various pages!

All you have to do is run:

```sh
bundle add bridgetown-inline-svg -g bridgetown_plugins
```

and then in any Liquid template or Markdown document, you can add an `svg` tag to inline your image:

{% raw %}
```liquid
{% svg path/to/my.svg %}
```
{% endraw %}

You can even set various HTML attributes like class names and dimensions, and the coolest part is your SVG files will be optimized by the plugin so they're potentially even smaller!

### Minify HTML Plugin

By using a static site generator like Bridgetown and deploying to a CDN like [Netlify](https://netlify.com){:rel="noopener"} or [Vercel](http://vercel.com){:rel="noopener"}, your site already has the potential to be one of the fastest on the internet! But there's always room for even more performance improvements, and that's where [the bridgetown-minify-html plugin by Mike Rogers](https://github.com/MikeRogers0/bridgetown-minify-html){:rel="noopener"} comes in.

Merely installing this plugin on your Bridgetown repo will establish a minification step at the end of your build process. This means every time you rebuild your site, it will "minify" your HTML output by stripping out all unnecessary whitespace, comments, and other parts of the markup that aren't strictly needed for parsing.

The result is smaller transfer sizes for your HTML, resulting in faster download speeds and happier users!

_Bonus tip:_ you can also [add PurgeCSS](https://github.com/bridgetownrb/automations#purgecss-post-build-hook){:rel="noopener"} to your build process to strip out any CSS code in your stylesheets that isn't in active use by HTML elements, resulting in a smaller CSS bundle size. Performance FTW!

### Summary

Wow, what a day! You've learned about how to incorporate content from a headless CMS using the Graphtown plugin, how to add JS interactivity to your site using Stimulus, how to include SVG images in your site for awesome visuals, and how to reduce your output HTML and CSS file sizes for maximum (ludicrous?) speed.

**What else can you do with Bridgetown? I can't wait to find out!**

----

_Want to set up your own website that's super fast and easy to customize? [Give Bridgetown a try today](/docs) and [let us know how it goes](/community)!_
{: .has-text-centered}