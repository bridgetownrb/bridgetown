---
title: Variables
order: 240
top_section: Configuration
category: variables
---

Bridgetown makes a variety of data available to templates. Files with [front matter](/docs/front-matter/) are subject to processing during the static generation process, and you can also use many of the same objects in dynamic routes as well.

The following is an overview of commonly-available data. We also have a [Ruby API Reference](https://api.bridgetownrb.com) available.

## Global Variables

{%@ Documentation::VariablesTable data: site.signals, scope: :global, description_size: :bigger  %}

## Site Variables

{%@ Documentation::VariablesTable data: site.signals, scope: :site, description_size: :bigger %}

## Resource Variables

{%@ Documentation::VariablesTable data: site.signals, scope: :resource, description_size: :bigger %}

{%@ Note do %}
  #### Using Custom Front Matter

  Any custom front matter that you specify will be available under
  `resource`. For example, if you specify `custom_css: true`
  in a resource’s front matter, that value will be available as `resource.data.custom_css`.

  If you specify front matter in a layout, access that via `layout`.
  For example, if you specify `class: full_page` in a layout’s front matter,
  that value will be available as `layout.data.class` in the layout.
{% end %}