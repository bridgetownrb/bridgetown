---
title: ERB and Beyond
order: 19
top_section: Templates
category: erb
---

Bridgetown's primary template language is [**Liquid**](/docs/liquid), due to historical reasons (its heritage coming from Jekyll) and well as Liquid's simple syntax and safe execution context making it ideal for designer-led template creation.

However, Bridgetown's implementation language, Ruby, has a rich history of promoting [ERB (Embedded RuBy)](https://docs.ruby-lang.org/en/2.7.0/ERB.html) for templates and view layers across a wide variety of tools and frameworks, and other template languages such as [Haml](http://haml.info) and [Slim](http://slim-lang.com) boast their fair share of enthusiasts.

So, starting with Bridgetown 0.16, you can now add ERB-based templates and pages (and partials too) to your site. In additional, there are plugins you can easily install for Haml and Slim as well. Under the hood, Bridgetown uses the [Tilt gem](https://github.com/rtomayko/tilt) to load and process these Ruby templates.

{% toc %}

## Usage

Simply define a page/document with an `.erb` extension, rather than `.html`. You'll still need to add front matter to the top of the file (or at the very least two lines of triple dashes `---`) for the file to get processed. In the Ruby code you embed, you'll be interacting with the underlying Ruby API for Bridgetown objects (aka `Bridgetown::Page`, `Bridgetown::Site`, etc.). Here's an example:

```eruby
---
title: I'm a page!
---

<h1><%= page.data[:title] %></h1>

<p>Welcome to <%= Bridgetown.name.to_s %>!</p>

<footer>Authored by <%= site.data[:authors].first[:name] %></footer>
```

Front matter is accessible via the `data` method on pages, posts, layouts, and other documents. Site config values are accessible via the `site.config` method, and loaded data files via `site.data` as you would expect.

In addition to `site`, you can also access the `site_drop` object which will provide similar access to various data and config values similar to the `site` variable in Liquid.

## Dot Access Hashes (available starting in v0.17.1)

Instead of traditional Ruby hash key access, you can use "dot access" instead for a more familar look (coming from Liquid templates, or perhaps ActiveRecord objects in Rails). For example:

```eruby
<%= post.data.title %>

<%= page.data.author %>

<%= site.data.authors.lakshmi.twitter.handle %>

<% # You can freely mix hash access and dot access: %>

<%= site.data.authors[page.data.author].github %>
```

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

<h1><%= page.data[:title] %></h1>

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

These helpers are actually methods of the `helper` object which is an instance of `Bridgetown::RubyTemplateView::Helpers`.

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
somevalue: 123
---

<h1><%= page.data[:title] %></h1>

<div>An ERB layout! <%= layout.name %> / somevalue: <%= layout.data[:somevalue] %></div>

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

If in your layout or a layout partial you need to output the paths to your Webpack assets, you can do so with a `webpack_path` helper just like with Liquid layouts:

```eruby
<link rel="stylesheet" href="<%= webpack_path :css %>" />
<script src="<%= webpack_path :js %>" defer></script>
```

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

## Capture Helper

If you need to capture a part of your template and store it in a variable for later use, you can use the `capture` helper.

```eruby
<% test_capturing = capture do %>
  This is how <%= "#{"cap"}turing" %> works!
<% end %>

<%= test_capturing.reverse %>
```

One interesting use case for capturing is you could assign the captured text to a layout data variable. Using memoization, you could calculate an expensive bit of template once and then reuse it either in that layout or in a partial.

Example:

```eruby
<% # add this code to a layout: %>
<% layout.data[:save_this_for_later] ||= capture do
  puts "saving this into the layout!"
%>An <%= "expensive " + "routine" %> to be saved<% end %>

Some text...

<%= partial "use_the_saved_variable" %>
```

```eruby
<% # src/_partials/_use_the_saved_variable.erb #>
Print this: <%= layout.data[:save_this_for_later] %>
```

Because of the use of the `||=` operator, you'll only see "saving this into the layout!" print to the console once when the site builds even if you use the layout on thousands of pages!

## Extensions and Permalinks

Sometimes you may want to output a file that doesn't end in `.html`. Perhaps you want to create a JSON index of a collection, or a special XML feed. If you have familiarity with other Ruby site generators or frameworks, you might instinctively reach for the solution where you use a double extension, say, `posts.json.erb` to indicate the final extension (`json`) and the template type (`erb`).

Bridgetown doesn't do anything with double extensions by default, but you can use them regardless—as long as you also set the file's permalink using front matter. Here's an example of `posts.json.erb` using a [custom permalink](/docs/structure/permalinks):

```eruby
---
permalink: /posts.json
---
[
  <%
    site.posts.docs.each_with_index do |post, index|
      last_item = index == site.posts.docs.length - 1
  %>
    {
      "title": <%= jsonify post.data[:title].strip %>,
      "url": "<%= absolute_url post.url %>"<%= "," unless last_item %>
    }
  <% end %>
]
```

The ensures the final relative URL will be `/posts.json`. (Of course you can also set the permalink to anything you want, regardless of the filename itself.)

## Custom Helpers

If you'd like to add your own custom template helpers, you can use the `helper` DSL within builder plugins. [Read this documentation to learn more](/docs/plugins/helpers).

Alternatively, you could open up the `Helpers` class and define additional methods:

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
Bridgetown::RubyTemplateView::Helpers.include MyFilters
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

## Haml and Slim

Bridgetown comes with ERB support out-of-the-box, but you can easily add support for either Haml or Slim by installing our officially supported plugins.

* [`bridgetown-haml`](https://github.com/bridgetownrb/bridgetown-haml)
* [`bridgetown-slim`](https://github.com/bridgetownrb/bridgetown-slim)

All you'd need to do is run `bundle add bridgetown-haml -g bridgetown_plugins` (or `bridgetown-slim`) to install the plugin, and then you can immediately start using `.haml` or `.slim` pages, layouts, and partials in your Bridgetown site.

## Turning off Liquid processing

For pages/documents, Bridgetown will automatically detect if you use Liquid tags {% raw %}(aka `{% %}` or `{{ }}`){% endraw %} and process your file with Liquid even if it's using ERB or another template language. This happens prior to any other conversions, so you can in theory using both Liquid and ERB in the same file.

You can however turn that off with front matter:

```yaml
render_with_liquid: false
```

If you wish to turn off Liquid across a variety of files, you can use [front matter defaults](/docs/configuration/front-matter-defaults) to set `render_with_liquid` to `false` without having to add that to each file's front matter.
