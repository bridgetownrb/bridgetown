---
title: Choose Your Template Engine
order: 140
top_section: Designing Your Site
category: template-engines
---

Bridgetown's default configured template language is **ERB** (Embedded RuBy). If you're familiar with PHP or other string-based template syntaxes in various programming languages, you should feel right at home.

However, you can use a variety of different template engines within Bridgetown simply by using the appropriate file extension (aka `.liquid` for Liquid), or by specifying the template engine in your resource's front matter. Out of the box, Bridgetown provides support for both **ERB**, **Serbea**, and **Liquid**, as well as a pure Ruby template type enhanced by **Streamlined**.

You can mix 'n' match template types easily. For example, Liquid's simple syntax and safe execution context make it ideal for designer-led template creation, so you could use Liquid for layouts but stick to ERB for code-intensive pages and other resources.

To configure a new Bridgetown site to use a language other than ERB as the default template engine regardless of file extension, use the `-t`/`--templates` option when running `bridgetown new`.

For documentation on how to use Ruby or Liquid syntax in Bridgetown content and templates:

<p style="margin-top:2em; display:flex; gap:1em; justify-content:center">
  <a href="/docs/template-engines/erb-and-beyond">
    <sl-button variant="primary" outline>
      ERB, Serbea, & More
      <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
  <a href="/docs/template-engines/liquid">
    <sl-button variant="primary" outline>
      Liquid
      <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
</p>

## Per-file Engine Configuration

When the default ERB template engine is configured, Bridgetown processes files through ERB even when they don't have an `.erb` extension. For example, `posts.json` or `about.md` or `authors.html` will all get processed through ERB during the build process (assuming front matter is present as is required by all resources).

As an initial step, you can use a different template engine based on extension alone. For example, `authors.liquid` would get processed through Liquid and output as `authors.html`. But there are a couple of drawbacks to that approach. If you wanted `posts.liquid` to be output as `posts.json`, you'd have to manually set a `permalink` in your front matter. In addition, if you wanted to write a document in Markdown but add Liquid tags in as well, you couldn't do that via file extension alone because the Markdown converter looks for files ending in `.md`.

So instead of doing that, you can switch template engines directly. All you need to do is use the `template_engine` front matter variable. You can do this on any page, document, or layout. For example, you could write `posts.json` but add `template_engine: liquid` to the front matter, and then you'd be all set. Write your template using Liquid syntax, get `posts.json` on output. In the Markdown scenario, you could still author `about.md` while adding Liquid tags to the content, and it would work exactly as you expect.

## Front Matter Defaults

Besides adding `template_engine` directly in your file's front matter, you could use [front matter defaults](/docs/content/front-matter-defaults) to specify a template engine for a folder or folder tree or files which match a particular "glob pattern". That way you could, say, use ERB for most of the site but use Serbea just for a certain group of files.

## Site-wide Configuration

Most likely, however, you'll want to switch your site wholesale from one engine to another. That's where `config/initializers.rb` (or `bridgetown.config.yml`) comes in. Let's say you want to default to Serbea. Simply add `template_engine :serbea` right in your config, and suddenly *everything* will get processed through Serbea regardless of file extension. (This will have been done for you if you used the `-t` option when running `bridgetown new`.) Liquid works in the same manner: `template_engine: liquid`. Write HTML, XML, Markdown, JSON, CSV, whatever you like—and _still_ access the full power of your template engine of choice.

It's worth noting that by combining Markdown, ERB/Serbea, components, and frontend JavaScript "sprinkles" (or "spices" as we like to say), you can author extremely sophisticated documents which boast stunning performance and SEO scores while at the same time providing impressive interactivity in the browser. This is quickly becoming a "best practice" in the web development industry, and Bridgetown will help get you there.

## Why Did Bridgetown Switch from Liquid?

Prior to Bridgetown 2.0, Liquid was the default template type. Liquid feels more akin to template engines like Mustache, Jinja, Nunjucks, Twig, and so forth—and it was the only default option in Bridgetown's progenitor, Jekyll.

But most Bridgetown developers will need more power (especially when writing [components](/docs/components)) or may already be familiar with Ruby and engines such as ERB. And some developers are looking to switch from [Middleman](https://middlemanapp.com) which uses ERB by default. Thus it makes sense to standardize around ERB.

In any case, the ability to "pick your flavor" of template engines on a site-by-site or file-by-file basis is one of Bridgetown's core strengths as a web framework.

## It's Up to You

Regardless of which template engine you pick, whether it's [ERB / Serbea / Streamlined](/docs/template-engines/erb-and-beyond), [Liquid](/docs/template-engines/liquid), or something else, Bridgetown has got you covered. We continue to look for ways to make switching engines easier while reducing the number of "sharp edges" that can arise to differences in how various template engines process content, so please don't hesitate to [let us know](/community) if you run in to any issues.
