---
title: Permalink Placeholders
order: 0
top_section: Configuration
category: plugins
---

Resources make use of a [permalink](/docs/content/permalinks) processor to determine where to save your transformed resources in the output folder tree. Within a permalink, various placeholders can be added which will subsequently be replaced with resource-specific data.

Placeholders start with a colon `:`. You can only have one placeholder within a path segment—in other words, `/my_path/:my_placeholder/` is valid, but `/my_path/:my_placeholder-and:another_placeholder/` is not.

To define new placeholders within a plugin, simply use the `permalink_placeholder` method of your builder. For example, if you wanted a placeholder to resolve a resource data, you could add:

```ruby
def build
  permalink_placeholder :ymd do |resource|
    "#{resource.date.strftime("%Y")}#{resource.date.strftime("%m")}#{resource.date.strftime("%d")}"
  end

  permalink_placeholder :y_m_d do |resource|
    "#{resource.date.strftime("%Y")}-#{resource.date.strftime("%m")}-#{resource.date.strftime("%d")}"
  end
end
```

Thus with a permalink key of `/blog/:ymd/:slug/`, you'd get `/blog/20211020/my-post/`, or for `/blog/:y_m_d/:slug/` you'd get `/blog/2021-10-20/my-post/`.

You can also call other placeholders procs from within your placeholder proc:

```ruby
def build
  permalink_placeholder :silly_title do |resource|
    resource.data.title == "Silly!" ? "silly" : placeholder_processors[:title].(resource)
  end
end
```
