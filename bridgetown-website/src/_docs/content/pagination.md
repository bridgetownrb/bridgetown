---
title: Pagination
hide_in_toc: true
order: 0
category: posts
---

{% render "docs/help_needed", page: page %}

Pagination support is built-in to Bridgetown, but it is not enabled by default. To enable it on your site, simply add:

```yml
pagination:
  enabled: true
```

to your config file.

## Page Configuration

To facilitate pagination on a page (like `index.html`, `blog.md`, etc.) then simply include configuration in the page's front matter:

``` yml
---
layout: page
pagination:
  enabled: true
---
```

Then you can use the `paginator.documents` logic to iterate through the documents.

{% raw %}
``` html
{% for post in paginator.documents %}
  <h1>{{ post.title }}</h1>
{% endfor %}
```
{% endraw %}

Normally the paginated documents are of a [Post](/docs/posts/) type, but to load a specific [Collection](/docs/collections/) type, just add a collection key like so:

```yml
pagination:
  enabled: true
  collection: tigers
```

By default, paginated documents will have 10 items per page. You can change this in your config by modifying the `per_page` key like so:

```yml
pagination:
  enabled: true
  per_page: 4
```

## Pagination Links

To display pagination links, simply use the `paginator` Liquid object as follows:

{% raw %}
``` html
{% if paginator.total_pages > 1 %}
  <ul class="pagination">
    {% if paginator.previous_page %}
    <li>
      <a href="{{ paginator.previous_page_path }}">Previous Page</a>
    </li>
    {% endif %}
    {% if paginator.next_page %}
    <li>
      <a href="{{ paginator.next_page_path }}">Next Page</a>
    </li>
    {% endif %}
  </ul>
{% endif %}
```
{% endraw %}

## Liquid Attributes Available

The `paginator` Liquid object provides the following attributes:

{% render "docs/variables_table", scope: site.data.bridgetown_variables.paginator %}
