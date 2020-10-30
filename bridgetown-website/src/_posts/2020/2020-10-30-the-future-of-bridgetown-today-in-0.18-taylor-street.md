---
title: "The Future of Bridgetown Today in v0.18 “Taylor Street”"
subtitle: |
  An action-packed release which sets the tone for the future of Bridgetown and the broader Ruby web developer community.
author: jared
category: release
---

We're excited to announce the [the release of Bridgetown 0.18](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.18.2), codenamed "Taylor Street". This is an action-packed release which sets the tone for the future of Bridgetown and the broader Ruby web developer community. As always, simply bump up your Gemfile's version and run `bundle update bridgetown` to get the latest goodies.

A few of the top highlights, then some additional thoughts:

* **Choose Your Own ~~Adventure~~ Template Engine.** Up 'till now, the default template engine available in Bridgetown has been Liquid. Don't get me wrong, Liquid is a perfectly serviceable template language, and it's certainly not going anywhere. But we feel like there is much to be gained by supporting a variety of languages—most notably the venerable ERB. Bridgetown has supported ERB as an option for several major releases already, but it could only be used on specific files ending in`.erb`.  Now it's possible to [configure your entire site to use ERB](/docs/erb-and-beyond)! And not only that, you can mix-and-match template engines on a per-file basis. Have your ERB and drink Liquid too. 😉
* **Render Ruby Components.** In addition to adding the `render` helper as an alternative to the `partial` helper in Ruby-based templates, you now have the ability to [render Ruby objects themselves as components](/docs/erb-and-beyond#rendering-ruby-components){:data-no-swup="true"}. All an object has to do is provide a `render_in` method and return a string. That's it! Ruby files are automatically loaded from `src/_components` as well as plugins with source manifests, so no additional setup is required. Does this mean…could it be…? Keep reading. 😎
* **link\_to and url\_for helpers.** Now in Ruby-based templates you can use the new `link_to` and `url_for` [helpers](/docs/erb-and-beyond#link-and-url-helpers){:data-no-swup="true"} to find pages, posts, and other documents on your site by filename reference or using the content object itself. This will feel familiar to anyone who's used Rails, and `url_for` is also aliased to `link` for those familiar with Liquid.
* **Additional progress on i18n.** We're continuing to add support for internationalization (i18n) in Bridgetown. While it's as yet undocumented, we recently worked on automatic locale switching from file to file and including a locale in the permalink (for example: `/en/my-page`, `/es/my-page`, etc.) when multiple locale-specific pages are present. Layouts and partials can take advantage of the "current" locale to output different content right when a page gets rendered.

And those are just the highlights! Read the full [Bridgetown 0.18 release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.18.2) for further details.

### The Future of the Ruby View Layer

It's time to talk about where all this is going. In the "render Ruby components" section above, you might be wondering: "wait a moment…if I can return a string from my Ruby object, can't I just render a template and return that?" And if you're wondering that, you might also be wondering "gee, that sounds a lot like what [ViewComponent](https://viewcomponent.org) does for Rails!"

Well, we've been wondering the same thing. While we're not officially announcing anything today, rest assured it's a primary goal for Bridgetown to become part of a _unified Ruby view layer_. This mean whether you're generating a static site with Bridgetown, serving up a dynamic app with Rails, or _using Rails to dynamically render a portion of a Bridgetown page_ (just a little something our scientists have been cooking up in the lab), we want you to be able to use the same Ruby component library everywhere. And with full Webpack support present in both Bridgetown and Rails, you would be able to write a Ruby component with a "sidecar" stylesheet and Javascript file and get the best of all possible worlds. (Want to write your _frontend_ in Ruby as well? [That's actually a thing!](https://github.com/rubys/ruby2js){:rel="noopener"})

Sound too good to be true? Well, it **is** true—all of it. This is what we've started to call the **DREAMstack**:

* **Delightful**
* **Ruby**
* **Expressing**
* **APIs and**
* **Markup**

We think Ruby is poised to explode in 2021 with the release of Ruby 3, Rails 6.1 and beyond, as well as the continued adoption of exciting tools which have recently emerged from the Rubyist communities (ViewComponent being one of them, along with [StimulusReflex](https://docs.stimulusreflex.com){:rel="noopener"}). We think Bridgetown will comprise an important part of the DREAMstack going forward and will bridge the gap (haha) between modern Jamstack deployment techniques and traditional Ruby on Rails apps.

When is that day coming? Soon, very soon. 🤞 The future is looking bright indeed.