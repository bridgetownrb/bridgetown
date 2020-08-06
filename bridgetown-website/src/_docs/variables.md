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

<div class="note">
  <h5>Top Tip: Use Custom Front Matter</h5>
  <p>
    Any custom front matter that you specify will be available under
    <code>page</code>. For example, if you specify <code>custom_css: true</code>
    in a page’s front matter, that value will be available as <code>page.custom_css</code>.
  </p>
  <p>
    If you specify front matter in a layout, access that via <code>layout</code>.
    For example, if you specify <code>class: full_page</code> in a layout’s front matter,
    that value will be available as <code>layout.class</code> in the layout and its parents.
  </p>
</div>

<!-- ## Paginator -->
