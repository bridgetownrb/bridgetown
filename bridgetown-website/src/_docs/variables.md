---
title: Variables
order: 240
top_section: Configuration
category: variables
---

Bridgetown traverses your site looking for files to process. Any files with
[front matter](/docs/front-matter/) are subject to processing. For each of these
files, Bridgetown makes a variety of data available via the [Liquid](/docs/template-engines/liquid/) template language.
The following is a reference of the available data.

## Global Variables

{%@ Documentation::VariablesTable data: site.data, scope: :global, description_size: :bigger  %}

## Site Variables

{%@ Documentation::VariablesTable data: site.data, scope: :site, description_size: :bigger %}

## Resource Variables

{%@ Documentation::VariablesTable data: site.data, scope: :resource, description_size: :bigger %}

{%@ Note do %}
  #### Top Tip: Use Custom Front Matter

  Any custom front matter that you specify will be available under
  `resource`. For example, if you specify `custom_css: true`
  in a resource’s front matter, that value will be available as `resource.data.custom_css`.

  If you specify front matter in a layout, access that via `layout`.
  For example, if you specify `class: full_page` in a layout’s front matter,
  that value will be available as `layout.data.class` in the layout.
{% end %}