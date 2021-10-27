---
title: Permalinks
hide_in_toc: true
order: 0
category: structure
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

<table class="settings bigger-output">
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>:year</code></p>
      </td>
      <td>
        <p>
          Four-digit year based on the resource's date.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:short_year</code></p>
      </td>
      <td>
        <p>
          Two-digit year based on the resource's date within its century (00..99).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:month</code></p>
      </td>
      <td>
        <p>
          Month based on the resource's date (01..12).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:i_month</code></p>
      </td>
      <td>
        <p>
          Month based on the resource's date without leading zeros (1..12).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:day</code></p>
      </td>
      <td>
        <p>
          Day of the month based on the resource's date (01..31).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:i_day</code></p>
      </td>
      <td>
        <p>
          Day of the month based on the resource's date without leading zeros (1..31).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:categories</code></p>
      </td>
      <td>
        <p>
          The specified categories for the resource. If a resource has multiple
          categories, Bridgetown will create a hierarchy (e.g. <code>/category1/category2</code>).
          Bridgetown automatically parses out double slashes in the URLs,
          so if no categories are present, it will ignore this.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:locale</code>, <code>:lang</code></p>
      </td>
      <td>
        <p>
          Adds the locale key of the current rendering context, if its not the default site locale.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:title</code></p>
      </td>
      <td>
        <p>
            Title from the resource's front mattter (aka `title: My Resource Title`), slugified (aka any character
            except numbers and letters is replaced as hyphen).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:slug</code></p>
      </td>
      <td>
        <p>
            Extracted from the resources’s filename. May be overridden via the resources’s <code>slug</code> front matter.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:name</code></p>
      </td>
      <td>
        <p>
            Extracted from the resources’s filename and cannot be overridden.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:path</code></p>
      </td>
      <td>
        <p>
          Constructs URL segments out of the relative path of the resource within its collection folder. Used by the **pages** collection as well as custom collections if no specific permalink config is provided.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:collection</code></p>
      </td>
      <td>
        <p>
          Outputs the label of the resource's custom collection (will be blank for the built-in pages and posts collections).
        </p>
      </td>
    </tr>
  </tbody>
</table>
