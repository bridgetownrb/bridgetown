---
title: Liquid
order: 0
top_section: Designing Your Site
category: template-engines
---

Bridgetown provides comprehensive support for rich presentation of data and design via the **Liquid** template language, available within documents as well as layouts and [components](/docs/components). If you find that Liquid doesn't suit your needs when building your site templates, [Bridgetown also allows for using ERB (Embedded RuBy)](/docs/template-engines/erb-and-beyond). You can mix and match ERB and Liquid templates freely throughout your site.

Generally in Liquid you output content using two curly braces e.g.
{% raw %}`{{ variable }}`{% endraw %} and perform logic statements by
surrounding them in a curly brace percentage sign e.g.
{% raw %}`{% if statement %}`{% endraw %}. To learn more about Liquid, check
out the [official Liquid Documentation](https://shopify.github.io/liquid/).

The ability to use Liquid within Markdown in posts and pages allows for advanced customization of your content pipeline. For example, you can write custom plugins to supply new Liquid [tags](/docs/plugins/tags) and [filters](/docs/plugins/filters) and use them throughout your site.

In addition to Liquid's standard suite of filters and tags, Bridgetown provides a number of useful additions to help you build your site:

<p style="margin-top:2em; display:flex; gap:1em; justify-content:center">
  <a href="/docs/liquid/filters">
    <sl-button type="primary" outline>
      Filters List
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
  <a href="/docs/liquid/tags">
    <sl-button type="primary" outline>
      Tags List
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
</p>
