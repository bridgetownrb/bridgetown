---
title: Filters
order: 0
top_section: Configuration
category: plugins
---

Filters are simple Ruby methods you can provide to [Liquid templates](/docs/template-engines/liquid) to transform input data in various ways. 

All methods take at least one argument which represents the input
of the filter, and you can also support multiple method arguments (and even optional ones). The return value will be the output of the filter.

Example:

```ruby
class Builders::Filters < SiteBuilder
  def build
    liquid_filter :cache_busting_url do |url|
      "http://www.example.com/#{url}?#{Time.now.to_i}"
    end
  end
end
```

```liquid
{% raw %}{{ "mydynamicfile.js" | cache_busting_url }}{% endraw %}
```

outputs:

```
http://www.example.com/mydynamicfile.js?1586194585
```

## Supporting Arguments

You can accept multiple arguments to your filter by simply adding them to your block or method, and optional ones are simply specified with a default value (perhaps `nil` or `false`). For example:

```ruby
class Builders::Filters < SiteBuilder
  def build
    liquid_filter :multiply_and_optionally_add do |input, multiply_by, add_by = nil|
      value = input * multiply_by
      add_by ? value + add_by : value
    end
  end
end
```

Then just use it like this:

```liquid
{% raw %}
5 times 10 equals {{ 5 | multiply_and_optionally_add:10 }}

  output: 5 times 10 equals 50

5 times 10 plus 3 equals {{ 5 | multiply_and_optionally_add:10, 3 }}

  output: 5 times 10 plus 3 equals 53
{% endraw %}
```

And of course you can chain any number of built-in and custom filters together:

```liquid
{% raw %}
5 times 10 minus 4 equals {{ 5 | multiply_and_optionally_add:10 | minus:4 }}

  output: 5 times 10 minus 4 equals 46
{% endraw %}
```

## Using Instance Methods

As with other parts of the Builder API, you can also use an instance method to register your filter:

```ruby
class Builders::Filters < SiteBuilder
  def build
    liquid_filter :cache_busting_url, :bust_it
  end

  def bust_it(url)
    "http://www.example.com/#{url}?#{Time.now.to_i}"
  end
end
```

If your filter name and method name are the same, you can omit the second argument.

## Filter Execution Scope

By default, the code within the filter block or method is executed within the scope of the builder object. This means you will not have access to other filters you may expecting to call. For example, if you want to call `slugify` from your filter, it will cause an error.

To remedy this, simply pass the `filters_scope: true` argument when defining a filter block. Then you can call other filters as part of your code block (but not methods within your builder).

```ruby
class Builders::Filters < SiteBuilder
  def build
    liquid_filter :slugify_and_upcase, filters_scope: true do |url|
      slugify(url).upcase
    end
  end
end
```

When using the filters scope, you have access to the Liquid context via `@context`, which provides current template objects such as the site and the page (e.g., `@context.registers[:site]`).

## When to use a Filter vs. a Tag

Filters are great when you want to transform input data from one format to another and potentially allow multiple transformations to be chained together. If instead you simply want to _insert_ a customized piece of content/HTML code into a page, then it's probably better to write a [Tag](/docs/plugins/tags/).

{%@ Note do %}
  If you prefer to use the Legacy API (aka `Liquid::Template.register_filter `) to construct Liquid filters, refer to the [Liquid documentation](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers) here.
{% end %}
