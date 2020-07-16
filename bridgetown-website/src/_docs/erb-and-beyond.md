---
title: ERB and Beyond
order: 19
top_section: Templates
category: erb
---

Bridgetown's primary template language is [**Liquid**](/docs/liquid), due to historical reasons (its heritage coming from Jekyll) and well as Liquid's simple syntax and safe execution context making it ideal for designer-led template creation.

However, Bridgetown's implementation language, Ruby, has a rich history of promoting [ERB (Embedded RuBy)](https://docs.ruby-lang.org/en/2.7.0/ERB.html) for templates and view layers across a wide variety of tools and frameworks, and other template languages such as [Haml](http://haml.info) and [Slim](http://slim-lang.com) boast their fair share of enthusiasts.

So, starting with Bridgetown 0.16, you can now add ERB-based templates and pages (and partials too) to your site. In additional, there are plugins you can easily install for Haml and Slim as well.

{% toc %}

## Usage

Simply define a page/document with an `.erb` extension, rather than `.html`. You'll still need to add front matter to the top of the file (or at the very least two lines of triple dashes `---`) for the file to get processed. In the Ruby code you embed, you'll be interacting with the underlying Ruby API for Bridgetown objects (aka `Bridgetown::Page`, `Bridgetown::Site`, etc.). Here's an example:

```eruby
---
title: I'm a page!
---

<h1><%= page[:title] %></h1>

<p>Welcome to <%= Bridgetown.name.to_s %>!</p>

<footer>Authored by <%= site.data[:authors].first[:name] %></footer>
```

In addition to `site`, you can also access the `site_drop` object which will provide similar access to various data and config values similar to the `site` variable in Liquid.

## Partials

To include a partial in your ERB template, add a `_partials` folder to your source folder, and save a partial starting with `_` in the filename. Then you can reference it using the `<%= partial "filename" %>` helper. For example, if we were to move the footer above into a partial:

```eruby
<!-- src/_partials/_author_footer.erb -->
<footer>Authored by <%= site.data[:authors].first[:name] %></footer>
```

```eruby
---
title: I'm a page!
---

<h1><%= page[:title] %></h1>

<p>Welcome to <%= Bridgetown.name %>!</p>

<%= partial "author_footer" %>
```

You can also pass variables to partials using either a `locals` hash or as keyword arguments:

```eruby
<%= partial "some/partial", key: "value", another_key: 123 %>

<%= partial "some/partial", locals: { key: "value", another_key: 123 } %>
```

## Liquid Filters and Components

Bridgetown includes access to some helpful [custom Liquid filters](/docs/liquid/filters) as helpers within your ERB templates:

```eruby
<!-- July 9th, 2020 -->
<%= date_to_string site.time, "ordinal" %>
```

These helpers are actually methods of the `helper` object which is an instance of `Bridgetown::RubyTemplateView::Helpers`.  If you wanted to add your own custom helpers to ERB templates, you could open the class up in a plugin and define additional methods:

```ruby
# plugins/site_builder.rb

Bridgetown::RubyTemplateView::Helpers.class_eval do
  def uppercase_string(input)
    input.upcase
  end
end
```

```eruby
<%= uppercase_string "i'm a string" %>

<!-- output: I'M A STRING -->
```

As a best practice, it would be best to define your helpers as methods of a dedicated `Module` which could then be used for both Liquid filters and ERB helpers simultaneously. Here's how you might go about that in your plugin:

```ruby
# plugins/filters.rb

module MyFilters
  def lowercase_string(input)
    input.downcase
  end
end

Liquid::Template.register_filter MyFilters

Bridgetown::RubyTemplateView::Helpers.class_eval do
  include MyFilters
end
```

Usage is pretty straightforward:

{% raw %}
```eruby
<%= lowercase_string "WAY DOWN LOW" %>
```

```Liquid
{{ "WAY DOWN LOW" | lowercase_string }}
```
{% endraw %}

In addition to using Liquid helpers, you can also render [Liquid components](/docs/components) from within your ERB templates via the `liquid_render` helper.

```eruby
<p>
  Rendering a component:
  <%= liquid_render "test_component", param: "Liquid FTW!" %>
</p>
```

{% raw %}
```html
<!-- src/_components/test_component.liquid -->
<span>{{ param }}</span>
```
{% endraw %}

## Layouts

You can add an `.erb` layout and use it in much the same way as a Liquid-based layout. You can freely mix'n'match ERB layouts with Liquid-based documents and Liquid-based layouts with ERB documents.

`src/_layouts/testing.erb`

```eruby
---
layout: default
---

<div>An ERB layout! <%= layout.name %></div>

<%= yield %>
```

{% raw %}
`src/page.html`
```Liquid
---
layout: testing
---

A standard Liquid page. {{ page.layout }}
```
{% endraw %}

## Markdown

When authoring a document using ERB, you might find yourself wanting to embed some Markdown within the document content. That's easy to do using a `markdownify` block:

```eruby
<% markdownify do %>
   ## I'm a header!

   * Yay!
   <%= "* Nifty!" %>
<% end %>
```

You can also pass any string variable via an inline block as well:

```eruby
<% markdownify { some_string_var } %>
```

## Haml and Slim

…plugins info…TBC…