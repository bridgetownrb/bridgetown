---
title: Tags
order: 0
top_section: Configuration
category: plugins
---

It's easy to add new [Liquid](/docs/template-engines/liquid/) tags (sometimes called "shortcodes") to your site. Tags provide extra functionality you can use inside of your Markdown content and any HTML template. Built-in examples added by Bridgetown include the `post_url` and `asset_path` tags. Below is an example of a custom Liquid tag that will output the time the page was rendered:

```ruby
class RenderTime < SiteBuilder
  def build
    liquid_tag :render_time do |attributes|
      "#{attributes} #{Time.now}"
    end
  end
end
```

In the example above, we can place the following tag anywhere in one of our
pages:

{% raw %}
```liquid
<p>{% render_time page rendered at: %}</p>
```
{% endraw %}

And we would get something like this on the page:

```html
<p>page rendered at: Tue June 22 23:38:47 –0500 2010</p>
```

## Tag Blocks

The `render_time` tag seen above can also be rewritten as a _tag block_. Look at this example:

```ruby
class RenderTime < SiteBuilder
  def build
    liquid_tag :render_time, as_block: true do |attributes, tag|
      "#{tag.content} #{Time.now}"
    end
  end
end
```

We can now use the tag block anywhere:

{% raw %}
```liquid
{% render_time %}
page rendered at:
{% endrender_time %}
```
{% endraw %}

And we would still get the same output as above on the page:

```html
<p>page rendered at: Tue June 22 23:38:47 –0500 2010</p>
```

{%@ Note type: :warning do %}
  In the above example, the tag block and the tag are both registered with the name `render_time`, but you'll want to avoid registering a tag and a tag block using the same name in the same project as this will lead to conflicts.
{% end %}

## Using Instance Methods

As with other parts of the Builder API, you can also use an instance method to register your tag:

```ruby
class Upcase < SiteBuilder
  def build
    liquid_tag :upcase, :upcase_tag, as_block: true
  end

  def upcase_tag(attributes, tag)
    tag.content.upcase
  end
end
```

If your tag name and method name are the same, you can omit the second argument.

{% raw %}
```liquid
{% upcase %}
i am upper case
{% endupcase %}
```
{% endraw %}

output: `I AM UPPER CASE`

## Supporting Multiple Attributes and Accessing Template Variables

If you'd like your tag to support multiple attributes separated by a comma, that's
easy to do with the following statement:

```ruby
param1, param2 = attributes.split(",").map(&:strip)
```

Then you could use the tag like this:

{% raw %}
```liquid
{% mytag value1, value2 %}
```
{% endraw %}

You can also access local Liquid template variables from within your tag by
accessing the `context` object, and that includes nested variables you would
normally access such as `{% raw %}{{ page.title }}{% endraw %}`.

Given a page with a title "My Exciting Webpage", you could reference it like this:

```ruby
tag.context["page"]["title"] # returns "My Exciting Webpage"
```

## When to use a Tag vs. a Filter

Tags and Tag Blocks are great when you simply want to insert a customized piece of
content/HTML code into a page. If instead you want to _transform_ input data from
one format to another and potentially allow multiple transformations to be chained
together, then it's probably better to write a [Filter](/docs/plugins/filters/).

{%@ Note do %}
If you prefer to use the Legacy API (aka `Liquid::Template.register_tag`) to
construct Liquid tags, refer to the [Liquid documentation](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers) here.
{% end %}