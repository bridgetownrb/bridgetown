---
title: Variables
order: 20
top_section: Templates
category: variables
---

Bridgetown traverses your site looking for files to process. Any files with
[front matter](/docs/front-matter/) are subject to processing. For each of these
files, Bridgetown makes a variety of data available via the [Liquid](/docs/liquid/) template language.
The following is a reference of the available data.

## Global Variables

{% render "docs/variables_table", scope: site.data.bridgetown_variables.global %}

## Site Variables

{% render "docs/variables_table", scope: site.data.bridgetown_variables.site %}

## Page Variables

{% render "docs/variables_table", scope: site.data.bridgetown_variables.page %}

{% rendercontent "docs/note", title: "Top Tip: Use Custom Front Matter" %}
  Any custom front matter that you specify will be available under
  `page`. For example, if you specify `custom_css: true`
  in a page’s front matter, that value will be available as `page.custom_css`.

  If you specify front matter in a layout, access that via `layout`.
  For example, if you specify `class: full_page` in a layout’s front matter,
  that value will be available as `layout.class` in the layout.
{% endrendercontent %}