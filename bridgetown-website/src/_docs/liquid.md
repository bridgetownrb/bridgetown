---
title: Liquid
order: 18
top_section: Templates
category: liquid
---

Bridgetown provides comprehensive support for rich presentation of data and design via the **Liquid** template language, available within documents as well as layouts and [components](/docs/components). If you find that Liquid doesn't suit your needs when building your site templates, [Bridgetown also allows for using ERB (Embedded RuBy)](/docs/erb-and-beyond). You can mix and match ERB and Liquid templates freely throughout your site.

Generally in Liquid you output content using two curly braces e.g.
{% raw %}`{{ variable }}`{% endraw %} and perform logic statements by
surrounding them in a curly brace percentage sign e.g.
{% raw %}`{% if statement %}`{% endraw %}. To learn more about Liquid, check
out the [official Liquid Documentation](https://shopify.github.io/liquid/).

The ability to use Liquid within Markdown in posts and pages allows for truly advanced customization of your content pipeline. For example, you can write custom Liquid [tags](/docs/plugins/tags) and [filters](/docs/plugins/filters) and use them throughout your site.

In addition to Liquid's standard suite of filters and tags, Bridgetown provides a number of useful additions to help you build your site:

<div class="buttons" style="justify-content: center" markdown="1">
[Filters List](/docs/liquid/filters/){:.button.is-warning.is-outlined}
[Tags List](/docs/liquid/tags/){:.button.is-warning.is-outlined}
</div>
