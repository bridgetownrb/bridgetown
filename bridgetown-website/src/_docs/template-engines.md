---
title: Choose Your Engine
order: 18
next_page_order: 18.5
top_section: Templates
category: engines
---

Bridgetown's primary template language is [**Liquid**](/docs/liquid), due to historical reasons (its heritage coming from Jekyll) and well as Liquid's simple syntax and safe execution context making it ideal for designer-led template creation.

However, starting in v0.18, you can configure Bridgetown to use [ERB](/docs/erb-and-beyond) as its primary template engine, and in addition you can specify your preferred template engine (including even Haml or Slim) on a per-file basis.

## But Why?

Liquid is a great way to start out if you're not that familiar with Ruby, because it feels more akin to template engines like Mustache, Jinja, Nunjucks, Twig, and so forth. Simple tags and filters, along with loops and conditional statements, let you construct templates quickly and easily.

But if you need more power (especially when writing [components](/docs/components)) or you're already familiar with Ruby and engines such as ERB, then the cognitive overhead to learn and stick with Liquid can actually become a hinderance. In addition, it's an important goal for Bridgetown to integrate well with a development workflow which already incorporates the [Ruby on Rails framework](https://rubyonrails.org){:rel="noopener"}. Or perhaps you're looking to switch from [Middleman](https://middlemanapp.com){:rel="noopener"} which uses ERB by default.

In any case, the ability to "pick your flavor" of template engines on a site-by-site or file-by-file basis is now one of Bridgetown's core strengths as a web framework.

{% rendercontent "docs/note" %}
For more information on how to use Ruby-based templates in general, take a look at [ERB and Beyond](/docs/erb-and-beyond).
{% endrendercontent %}

## Per-file Engine Configuration

When the default Liquid template engine is configured, Bridgetown processes files through Liquid even when they don't have a `.liquid` extension. For example, `posts.json` or `about.md` or `authors.html` will all get processed through Liquid during the build process.

As an initial step, you can use a different template engine based on extension alone. For example, `authors.erb` would get processed through ERB and output as `authors.html`. But there are a couple of drawbacks to that approach. If you wanted `posts.erb` to be output as `posts.json`, you'd have to manually set a `permalink` in your front matter. In addition, if you wanted to write a document in Markdown but add ERB tags in as well, you couldn't do that via file extension alone because the Markdown converter looks for files ending in `.md`.

So instead of doing that, you can switch template engines directly. All you need to do is use the `template_engine` front matter variable. You can do this on any page, document, or layout. For example, you could write `posts.json` but add `template_engine: erb` to the front matter, and then you'd be all set. Write your template using ERB syntax, get `posts.json` on output. In the Markdown scenario, you could still author `about.md` while adding ERB tags to the content, and it would work exactly as you expect.

## Front Matter Defaults

Besides adding `template_engine` directly in your file's front matter, you could use [front matter defaults](/docs/configuration/front-matter-defaults) to specify a template engine for a folder or folder tree or files which match a particular "glob pattern". That way you could, say, use Liquid for most of the site but use ERB just for a certain group of files.

## Site-wide Configuration

Most likely, however, you'll want to switch your site wholesale from one engine to another. That's where `bridgetown.config.yml` comes in. Simply add `template_engine: erb` right in your config, and suddenly *everything* will get processed through ERB regardless of file extension. Write HTML, XML, Markdown, JSON, CSV, whatever you like—and _still_ access the full power of your Ruby template language of choice.

It's worth noting that by combining Markdown, ERB, components, and frontend Javascript "sprinkles" (or "spices" as we like to say), you can author extremely sophisticated documents which boast stunning performance and SEO scores while at the same time providing impressive interactivity in the browser. This is quickly becoming a "best practice" in the web development industry, and Bridgetown will help get you there.

{% rendercontent "docs/note", type: "warning", extra_margin: true %}
While it's true you can use ERB site-wide, the [Haml](https://github.com/bridgetownrb/bridgetown-haml){:rel="noopener"} and [Slim](https://github.com/bridgetownrb/bridgetown-slim){:rel="noopener"} plugins do _not_ allow site-wide configuration. That's because both Haml and Slim start with pure HTML/XML output using special syntax, and if you want to do something else like write Markdown or JSON, you'll have to use their "embedded" language support. Read their documentation for further details.
{% endrendercontent %}

## It's Up to You

Regardless of which template engine you pick, whether it's [Liquid](/docs/liquid) or [ERB](/docs/erb-and-beyond) or something else, Bridgetown has got you covered. We continue to look for ways to make switching engines easier while reducing the number of "sharp edges" that can arise to differences in how various template engines process content, so please don't hesitate to [let us know](/docs/community) if you run in to any issues.