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

To facilitate pagination on any given page (like `index.html`, `blog.md`, etc.) then simply include configuration in the resource's front matter to specify which collection you'd like to paginate through:

``` yml
---
layout: page
pagination:
  collection: posts
---
```

Then you can use the `paginator.resources` logic to iterate through the collection's resources.

{% raw %}
``` html
{% for post in paginator.resources %}
  <h1>{{ post.data.title }}</h1>
{% endfor %}
```
{% endraw %}

By default, paginated pages will have 10 items per page. You can change this in your config by modifying the `per_page` key like so:

```yml
pagination:
  enabled: true
  per_page: 4
```

## Excluding a Resource from the Paginator

You can exclude a resource from being included in the paginated items list.

```yml
exclude_from_pagination: true
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
