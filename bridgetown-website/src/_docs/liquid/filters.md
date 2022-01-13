---
title: Liquid Filters
top_section: Designing Your Site
order: 0
category: template-engines
shopify_filter_url: https://shopify.github.io/liquid/filters/
shopify_filters:
- abs
- append
- at_least
- at_most
- capitalize
- ceil
- compact
- concat
- date
- default
- divided_by
- downcase
- escape
- escape_once
- first
- floor
- join
- last
- lstrip
- map
- minus
- modulo
- newline_to_br
- plus
- prepend
- remove
- remove_first
- replace
- replace_first
- reverse
- round
- rstrip
- size
- slice
- sort
- sort_natural
- split
- strip
- strip_html
- strip_newlines
- times
- truncate
- truncatewords
- uniq
- upcase
- url_decode
- url_encode
---

All of the standard Liquid [filters](#standard-liquid-filters) are supported (see below).

To make common tasks easier, Bridgetown even adds a few handy filters of its own,
all of which you can find on this page. You can also create your own filters
using [plugins](/docs/plugins/filters).

<table class="settings bigger-output">
  <thead>
    <tr>
      <th>Description</th>
      <th><ui-label class="filter">Filter</ui-label> and <ui-label class="output">Output</ui-label></th>
    </tr>
  </thead>
  <tbody>
    {% site.data.bridgetown_variables.liquid_filters.each do |filter| %}
      <tr>
        <td>
          <p class="name"><strong>{{ filter.name }}</strong></p>
          <p>
            {{ filter.description | safe }}
          </p>
        </td>
        <td class="align-center">
          {% filter.examples.each do |example| %}
            <p><code class="filter">{{ example.input }}</code></p>
            {% if example.output %}<p><code class="output">{{ example.output }}</code></p>{% end %}
          {% end %}
        </td>
      </tr>
    {% end %}
  </tbody>
</table>

### Options for the `slugify` filter

The `slugify` filter accepts an option, each specifying what to filter.
The default is `pretty` (unless the `slugify_mode` setting is changed in the site config). They are as follows (with what they filter):

- `none`: no characters
- `raw`: spaces
- `default`: spaces and non-alphanumeric characters
- `pretty`: spaces and non-alphanumeric characters except for `._~!$&'()+,;=@`
- `ascii`: spaces, non-alphanumeric, and non-ASCII characters
- `latin`: like `default`, except Latin characters are first transliterated (e.g. `àèïòü` to `aeiou`).

### Detecting `nil` values with `where` filter

You can use the `where` filter to detect documents and pages with properties that are `nil` or `""`. For example,

{% raw %}
```liquid
// Using `nil` to select posts that either do not have `my_prop`
// defined or `my_prop` has been set to `nil` explicitly.
{% assign filtered_posts = collections.posts.resources | where: 'my_prop', nil %}
```
{% endraw %}

{% raw %}
```liquid
// Using Liquid's special literal `empty` or `blank` to select
// posts that have `my_prop` set to an empty value.
{% assign filtered_posts = collections.posts.resources | where: 'my_prop', empty %}
```
{% endraw %}

### Binary operators in `where_exp` filter

You can use Liquid binary operators `or` and `and` in the expression passed to the `where_exp` filter to employ multiple
conditionals in the operation.

For example, to get a list of documents on English horror flicks, one could use the following snippet:

{% raw %}
```liquid
{{ collections.movies.resources | where_exp: "item", "item.genre == 'horror' and item.language == 'English'" }}
```
{% endraw %}

Or to get a list of comic-book based movies, one may use the following:

{% raw %}
```liquid
{{ collections.movies.resources | where_exp: "item", "item.sub_genre == 'MCU' or item.sub_genre == 'DCEU'" }}
```
{% endraw %}

### Standard Liquid Filters

For your convenience, here is the list of all [Liquid filters]({{ resource.data.shopify_filter_url }}) with links to examples in the official Liquid documentation.

{% resource.data.shopify_filters.each do |filter| %}
- [{{ filter }}]({{ filter | prepend: resource.data.shopify_filter_url | append: '/' }})
{% end %}
