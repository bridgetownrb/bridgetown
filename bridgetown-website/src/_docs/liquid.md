---
title: Liquid
order: 16
top_section: Templates
category: liquid
---

Bridgetown uses the **Liquid** templating language
to process templates and content documents.

Generally in Liquid you output content using two curly braces e.g.
{% raw %}`{{ variable }}`{% endraw %} and perform logic statements by
surrounding them in a curly brace percentage sign e.g.
{% raw %}`{% if statement %}`{% endraw %}. To learn more about Liquid, check
out the [official Liquid Documentation](https://shopify.github.io/liquid/).

The ability to use Liquid within Markdown in posts and pages allows for truly advanced customization of your content pipeline. For example, you can write custom Liquid [tags](/docs/plugins/tags) and [filters](/docs/plugins/filters) and use them throughout your site.

In addition to the standard suite of filters and tags included in Liquid, Bridgetown provides a number of useful additions to help you build your site:

* [Filters]({{ '/docs/liquid/filters/' | relative_url }})
* [Tags]({{ '/docs/liquid/tags/' | relative_url }})
