---
title: Pagination
order: 0
top_section: Writing Content
category: resources
---

Pagination support is built-in to Bridgetown, but it is not enabled by default. You can enable it in the config file using:

{%@ Documentation::Multilang do %}
```ruby
# within Bridgetown.configure do |config| block
pagination do
  enabled true
end
```
===
{% raw %}
```yaml
pagination:
  enabled: true
```
{% endraw %}
{% end %}

## Page Configuration

To facilitate pagination on any given page (like `index.html`, `blog.md`, etc.) include configuration in the resource's front matter to specify which collection you'd like to paginate through:

``` yml
---
layout: page
paginate:
  collection: posts
---
```

Then you can use the `paginator.resources` logic to iterate through the collection's resources.

{%@ Documentation::Multilang do %}
```erb
# for earlier versions paginator.resources.each
<% paginator.each do |post| %>
  <h1>%= post.data.title %></h1>
<% end %>
```
===
{% raw %}
```liquid
{% for post in paginator.resources %}
  <h1>{{ post.data.title }}</h1>
{% endfor %}
```
{% endraw %}
{% end %}

By default, paginated pages will have 10 items per page. You can change this in your config by modifying the `per_page` key like so:

```yml
paginate:
  collection: posts
  per_page: 4
```

You can also control the sort field and order of the paginated result set separately from the default sort of the collection:

```yml
paginate:
  collection: movies
  sort_field: rating
  sort_reverse: true
```

## Attributes for Defining Pagination

{%@ Documentation::VariablesTable data: site.data, scope: :paginator_attr, description_size: :bigger %}

## Excluding a Resource from the Paginator

You can exclude a resource from being included in the paginated items list.

```yml
exclude_from_pagination: true
```

## Pagination Links

To display pagination links, use the `paginator` Liquid object as follows:

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

{%@ Documentation::VariablesTable data: site.data, scope: :paginator, description_size: :bigger %}

