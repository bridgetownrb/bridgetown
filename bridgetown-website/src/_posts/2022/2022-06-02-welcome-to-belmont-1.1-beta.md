---
title: "Welcome to Belmont and the Beta Release of Bridgetown 1.1"
subtitle: "I18n, Lit components, Inspectors, and Sass: What's new for Bridgetown as we head into Q3 2022."
author: jared
category: release
---

Hot off the heels of our Bridgetown 1.0 release, we return to announce the beta of v1.1 "Belmont" and an array of fun new features. [The new edge documentation is available here.](https://edge.bridgetownrb.com)

To upgrade and try out the beta of 1.1, edit your Gemfile:

```rb
gem "bridgetown", "~> 1.1.0.beta2"
```

and then run:

```sh
bundle update bridgetown # or just bundle update
```

You'll also want to run `bin/bridgetown esbuild update`  or `bin/bridgetown webpack update` to get the latest default  frontend configuration installed.

**So what's new in 1.1? Let's find out!**

### Internationalization (I18n)

You can now configure multiple locales for your website and set which particular locale should be considered "the default". The [Ruby I18n](https://github.com/ruby-i18n/i18n) gem aids in storing and accessing translations, the same library used by Ruby on Rails. Thus many of the same conventions will apply if you're already familiar with i18n in Rails. There are also several mechanisms for defining translated variants of your Markdown & HTML content and for switching freely between the locale variants.

[Check out the docs on i18n](https://edge.bridgetownrb.com/docs/internationalization) to see how to add new locales to your website.

### HTML & XML Inspectors

The Inspectors API provides a useful way to review or manipulate the output of your HTML or XML resources. The API utilizes [Nokogiri](https://nokogiri.org), a Ruby gem which lets you work with a DOM-like API directly on the nodes of a document tree.

Here's an example of an Inspector which automatically adds `target="_blank"` attributes on all outgoing links:

```ruby
class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("a").each do |anchor|
        next if anchor[:target]

        next unless anchor[:href]&.starts_with?("http") && !anchor[:href]&.include?(site.config.url)

        anchor[:target] = "_blank"
      end
    end
  end
end
```

[Check out the docs on Inspectors](https://edge.bridgetownrb.com/docs/plugins/inspectors) to see how you can manipulate the output of both HTML & XML content on your website. (Hat tip to [Cory LaViska](https://www.abeautifulsite.net) who provided the inspiration for this feature!)

### Automated Installations of Lit, Shoelace, Ruby2JS, and Open Props

Bridgetown has a feature called Bundled Configurations which lets you install popular and useful tools or integrations in an automated fashion. In Bridgetown 1.1, we've added new configurations for:

* **[Lit](https://edge.bridgetownrb.com/docs/components/lit)**: For advanced frontend interactivity. Every Lit component is a native web component, with the superpower of interoperability. This makes Lit ideal for building shareable components, design systems, or maintainable, future-ready sites and apps.
* **[Shoelace](https://edge.bridgetownrb.com/docs/bundled-configurations#shoelace)**: An instant design system and UI component library at your fingertips. Use CSS variables and shadow parts to customize the look and feel of Shoelace components in any way you like. 
* **[Ruby2JS](https://edge.bridgetownrb.com/docs/bundled-configurations#ruby2js)**:  An extensible Ruby to modern JavaScript transpiler you can use in production today. It produces JavaScript that looks hand-crafted, rather than machine generated.
* **[Open Props](https://edge.bridgetownrb.com/docs/bundled-configurations#open-props)**: A collection of “supercharged CSS variables” and optional normalize stylesheet to help you create your own design system.

Along with prior configurations such as Turbo and Render, you can go from brand-new project to deployed production website in less time than ever!

### Phrase Highlighting in Markdown and Default Syntax Highlighting

We now support using `==` or `::` in Markdown files to denote highlighted portions of text using the `<mark>` HTML tag. So `This should be ==highlighted== folks!` will get converted to `This should be <mark>highlighted</mark> folks!`.

In addition, we now ship a default stylesheet for syntax highlighting of code in your Markdown files. No more hunting around for a theme right out of the gate!

### And Many More…

There are plenty of other small improvements and fixes in Bridgetown 1.1, so [be sure to read the release notes](https://github.com/bridgetownrb/bridgetown/releases/tag/v1.1.0.beta2). And no doubt a few more are waiting in the wings before the final release of v1.1.

We greatly value your feedback in order to fix bugs as well as improve documentation. Please visit our [Community page](/community) to learn how to submit feedback, request help, and report issues. And a big shout out to our contributors and all who help make Bridgetown a thriving and growing community. Keep your spirits high!