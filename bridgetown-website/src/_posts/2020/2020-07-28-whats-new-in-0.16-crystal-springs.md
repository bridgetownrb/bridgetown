---
title: "To ERB and Beyond! What’s New in Bridgetown 0.16 “Crystal Springs”"
subtitle: It's the height of summer, and we’re here with a real treat for Rubyists everywhere! At last you can have your cake and eat it too with the release of Bridgetown 0.16 “Crystal Springs”—write site templates in your choice of ERB, Haml, or Slim all while enjoying the benefits of Bridgetown’s Jekyll-inspired ease of configuration and rapid content development process.
author: jared
category: release
---

It's the height of summer, and we're here with a real treat for Rubyists everywhere! At last you can have your cake and eat it too with the release of [Bridgetown 0.16 "Crystal Springs"](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.16.0)—write site templates in your choice of ERB, Haml, or Slim all while enjoying the benefits of Bridgetown's Jekyll-inspired ease of configuration and rapid content development process.

To upgrade your Bridgetown site, simply edit your Gemfile:

```ruby
gem "bridgetown", "~> 0.16"
```

And run `bundle update bridgetown`.

### ERB, Haml, and Slim (oh my!)

Out of the box, Bridgetown 0.16 supports ERB page templates, layouts, and partials, and you can install officially-supported plugins to add handlers for Haml and Slim. This is a deep integration which gives you the ability to:

* Freely mix'n'match ERB/Haml/Slim with existing Liquid templates. A page processed with Liquid can use a layout written in ERB, and visa-versa. You can also render Liquid components directly using the `liquid_render` helper.
* Add a `src/_partials` folder and render any number of ERB/Haml/Slim partials with both local and template-level variables from any other template.
* Use ERB-specific helpers like `capture` and `markdown` which provide great flexibility in combining Ruby code with content.

Not only that, but ERB/Haml/Slim templates are automatically supplied with the full range of existing Liquid filters as helper methods, so you can write statements like `jsonify somevalue` and `absolute_url post.url` (the equivalent of `somevalue | jsonify` and `post.url | absolute_url` in Liquid).

Want to add your own helpers? No problem! Simply decorate the `Bridgetown::RubyTemplateView::Helpers` class or add a mixin.

All this and more is well-documented in [ERB and Beyond](/docs/erb-and-beyond). If you run into any problems or have suggestions on how to improve template support, [please let us know!](/community)

### Class Map Liquid Tag

One of the patterns we've noticed that can get really messy when writing [Liquid components](/docs/components) is trying to toggle on/off CSS classes based on input variables. It requires lots of `assign` statements and conditionals to get the right string to pass to the `class` attribute of an HTML element.

But not anymore! Introducing `class_map`:

{% raw %}
```liquid
<div class="{% class_map has-centered-text: page.centered, is-small: small-var %}">
  …
</div>
```
{% endraw %}

In this example, the `class_map` tag will include `has-text-centered` only if `page.centered` is truthy, and likewise `is-small` only if `small-var` is truthy. If you need to run a comparison with a specific value, you'll still need to use `assign` but it'll still be simpler than in the past:

{% raw %}
```liquid
{% if product.feature_in == "socks" %}{% assign should_bold = true %}{% endif %}
<div class="{% class_map product: true, bold-text: should_bold, float-right: true %}">
  …
</div>
```
{% endraw %}

### Codebase Grooming

We're continuing to invest time and and effort in improving overall codebase quality by refactoring large objects into multiple concerns, adding better YARD documentation, and offering improved stability when there are Webpack build errors.

In addition, we've switched the default branch name of our repo from `master` to `main`—and you're free to use `main` (or any other name) as well for your [automation](/docs/automations) repos on GitHub as the Bridgetown `apply` command will now check the GitHub API for the default branch name instead of assuming it's always `master`.

For the full CHANGELOG, [read the 0.16.0 release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.16.0).

### Special Thanks to Our Contributors!

Once again, we'd like to thank all who contributed to this release ([myself](https://github.com/jaredcwhite), along with [MikeRogers0](https://github.com/MikeRogers0), [ParamagicDev](https://github.com/ParamagicDev), and [andrewmcodes](https://github.com/andrewmcodes)), as well as all who supplied feedback and filed issues. You rock!

Finally, if you've benefited at all in any way from Bridgetown, [please consider becoming a sponsor on GitHub](https://github.com/sponsors/jaredcwhite) so we can continue to work extensively on Bridgetown and push the Ruby and Jamstack ecosystems forward. ❤️
