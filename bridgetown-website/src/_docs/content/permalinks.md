---
title: Permalinks
order: 0
top_section: Writing Content
category: resources
---

A permalink is simply the determination of what the output URL of your [resource](/docs/resources) will be. Every resource uses a _permalink processer_ to figure out where to save your transformed resource in the output folder tree.

Resources in the **pages** collection are the most straightforward. The filenames and folder structure of your pages will result in matching output URLs. For example, a file saved at `src/_pages/this/is/great.md` would be output to `/this/is/great/`.

For resources in the **posts** collection, Bridgetown ships with few permalink "styles". The posts permalink style is configured by using the `permalink` key in the config file. If the key isn't present, the default is `pretty`.

The available styles are:

* `pretty`: `/[locale]/:categories/:year/:month/:day/:slug/`
* `pretty_ext`: `/[locale]/:categories/:year/:month/:day/:slug.*`
* `simple`: `/[locale]/:categories/:slug/`
* `simple_ext`: `[locale]/:categories/:slug.*`

(Including `.*` at the end simply means it will output the resource with its own slug and extension. Alternatively, `/` at the end will put the resource in a folder of that slug with `index.html` inside.)

To set a permalink style or template for a **custom collection**, add it to your collection metadata in `bridgetown.config.yml`. For example:

```yaml
collections:
  articles:
    permalink: pretty
```

would make your articles collection behave the same as posts. Or you can create your own template:

```yaml
collections:
  articles:
    permalink: /lots-of/:collection/:year/:title/
```

This would result in URLs such as `/lots-of/articles/2021/super-neato/`.

### Placeholders

All of the segments you see above starting with a colon, such as `:year` or `:slug`, are called **placeholders**. Bridgetown ships with a number of placeholders, but you can also create your own! Simply use the `register_placeholder` in a plugin, perhaps at the bottom of your `plugins/site_builder.rb` file. For example, if you wanted a placeholder to resolve a resource data, you could add:

```ruby
Bridgetown::Resource::PermalinkProcessor.register_placeholder :ymd, ->(resource) do
  "#{resource.date.strftime("%Y")}#{resource.date.strftime("%m")}#{resource.date.strftime("%d")}"
end

Bridgetown::Resource::PermalinkProcessor.register_placeholder :y_m_d, ->(resource) do
  "#{resource.date.strftime("%Y")}-#{resource.date.strftime("%m")}-#{resource.date.strftime("%d")}"
end
```

Thus with a permalink key of `/blog/:ymd/:slug/`, you'd get `/blog/20211020/my-post/`, or for `/blog/:y_m_d/:slug/` you'd get `/blog/2021-10-20/my-post/`.

Here's the full list of built-in placeholders available:

{%@ Documentation::VariablesTable data: site.data, scope: :permalinks %}
