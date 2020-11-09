---
title: ERB and Beyond
order: 19
top_section: Templates
category: erb
template_engine: erb
---

Bridgetown's primary template language is [**Liquid**](/docs/liquid), due to historical reasons (its heritage coming from Jekyll) and well as Liquid's simple syntax and safe execution context making it ideal for designer-led template creation.

However, Bridgetown's implementation language, Ruby, has a rich history of promoting [ERB (Embedded RuBy)](https://docs.ruby-lang.org/en/2.7.0/ERB.html) for templates and view layers across a wide variety of tools and frameworks, and other template languages such as [Haml](http://haml.info) and [Slim](http://slim-lang.com) boast their fair share of enthusiasts.

So, starting with Bridgetown 0.16, you can now add ERB-based templates and pages (and partials too) to your site. In additional, there are plugins you can easily install for Haml and Slim as well. Under the hood, Bridgetown uses the [Tilt gem](https://github.com/rtomayko/tilt) to load and process these Ruby templates.

Interested in switching your entire site to use ERB? [It's now possible to do that too!](/docs/template-engines)

<%= toc %>

## Usage

Simply define a page/document with an `.erb` extension, rather than `.html`. You'll still need to add front matter to the top of the file (or at the very least two lines of triple dashes `---`) for the file to get processed. In the Ruby code you embed, you'll be interacting with the underlying Ruby API for Bridgetown objects (aka `Bridgetown::Page`, `Bridgetown::Site`, etc.). Here's an example:

```eruby
---
title: I'm a page!
---

<h1><%%= page.data[:title] %></h1>

<p>Welcome to <%%= Bridgetown.name.to_s %>!</p>

<footer>Authored by <%%= site.data[:authors].first[:name] %></footer>
```

Front matter is accessible via the `data` method on pages, posts, layouts, and other documents. Site config values are accessible via the `site.config` method, and loaded data files via `site.data` as you would expect.

In addition to `site`, you can also access the `site_drop` object which will provide similar access to various data and config values similar to the `site` variable in Liquid.

If you need to escape an ERB tag (to use it in a code sample for example), use two percent signs:

~~~md
Here's my **Markdown** file.

```erb
And my <%%%= "ERB code sample" %>
```
~~~

## Dot Access Hashes

Instead of traditional Ruby hash key access, you can use "dot access" instead for a more familar look (coming from Liquid templates, or perhaps ActiveRecord objects in Rails). For example:

```eruby
<%%= post.data.title %>

<%%= page.data.author %>

<%%= site.data.authors.lakshmi.twitter.handle %>

<%% # You can freely mix hash access and dot access: %>

<%%= site.data.authors[page.data.author].github %>
```

## Partials

To include a partial in your ERB template, add a `_partials` folder to your source folder, and save a partial starting with `_` in the filename. Then you can reference it using the `<%%= render "filename" %>` helper (or use the `partial` alias if you're more comfortable with that). For example, if we were to move the footer above into a partial:

```eruby
<!-- src/_partials/_author_footer.erb -->
<footer>Authored by <%%= site.data[:authors].first[:name] %></footer>
```

```eruby
---
title: I'm a page!
---

<h1><%%= page.data[:title] %></h1>

<p>Welcome to <%%= Bridgetown.name %>!</p>

<%%= render "author_footer" %>
```

You can also pass variables to partials using either a `locals` hash or as keyword arguments:

```eruby
<%%= render "some/partial", key: "value", another_key: 123 %>

<%%= render "some/partial", locals: { key: "value", another_key: 123 } %>
```

## Rendering Ruby Components

Starting in Bridgetown 0.18, you can even render Ruby objects directly! This opens the door to a fully-featured view component architecture for ERB and other Ruby-based template languages in Bridgetown, and we will have more to announce on that front going forward.

Bridgetown automatically loads `.rb` files you add to the `src/_components` folder, so that's likely where you'll want to save your component class definitions. It also load components from plugins which provide a `components` source manifest. Bridgetown's component loader is based on [Zeitwerk](https://github.com/fxn/zeitwerk){:rel="noopener"}, so you'll need to make sure you class names and namespaces line up with your component folder hierarchy.

To create a Ruby component, all you have to do is define a `render_in` method which accepts a single `view_context` argument as well as optional block. Whatever string value you return from the method will be inserted into the template. For example:

```ruby
class MyComponent
  def render_in(view_context, &block)
    "Hello from MyComponent!"
  end
end
```

```eruby
<%%= render MyComponent.new %>

  output: Hello from MyComponent!
```

To pass variables along to a component, simply write an `initialize` method:

```ruby
class FieldComponent
  def initialize(type: "text", name:, label:)
    @type, @name, @label = type, name, label
  end

  def render_in(view_context)
    <<~HTML
    <field-component>
      <label>#{@label}</label>
      <input type="#{@type}" name="#{@name}" />
    </field-component>
    HTML
  end
end
```

```eruby
<%%= render FieldComponent.new(type: "email", name: "email_address", label: "Email Address") %>

  output:
  <field-component>
    <label>Email Address</label>
    <input type="email" name="email_address" />
  </field-component>
```

<%= liquid_render "docs/note", type: "warning", extra_margin: true do %>
Bear in mind that Ruby components aren't accessible from Liquid templates. So if you need a component which can be used in either templating system, consider writing a Liquid component (see below).
<% end %>

## Liquid Filters, Tags, and Components

Bridgetown includes access to some helpful [Liquid filters](/docs/liquid/filters) as helpers within your ERB templates:

```eruby
<!-- July 9th, 2020 -->
<%%= date_to_string site.time, "ordinal" %>
```

These helpers are actually methods of the `helper` object which is an instance of `Bridgetown::RubyTemplateView::Helpers`.

A few Liquid tags are also available as helpers too, such as [`class_map`](/docs/liquid/tags#class-map-tag){:data-no-swup="true"} and [`webpack_path`](/docs/frontend-assets#linking-to-the-output-bundles){:data-no-swup="true"}.

In addition to using Liquid helpers, you can also render [Liquid components](/docs/components) from within your ERB templates via the `liquid_render` helper.

```eruby
<p>
  Rendering a component:
  <%%= liquid_render "test_component", param: "Liquid FTW!" %>
</p>
```

```html
<!-- src/_components/test_component.liquid -->
<span>{{ param }}</span>
```

## Layouts

You can add an `.erb` layout and use it in much the same way as a Liquid-based layout. You can freely mix'n'match ERB layouts with Liquid-based documents and Liquid-based layouts with ERB documents.

`src/_layouts/testing.erb`

```eruby
---
layout: default
somevalue: 123
---

<h1><%%= page.data[:title] %></h1>

<div>An ERB layout! <%%= layout.name %> / somevalue: <%%= layout.data[:somevalue] %></div>

<%%= yield %>
```

`src/page.html`
```Liquid
---
layout: testing
---

A standard Liquid page. {{ page.layout }}
```

If in your layout or a layout partial you need to output the paths to your Webpack assets, you can do so with a `webpack_path` helper just like with Liquid layouts:

```eruby
<link rel="stylesheet" href="<%%= webpack_path :css %>" />
<script src="<%%= webpack_path :js %>" defer></script>
```

## Markdown

When authoring a document using ERB, you might find yourself wanting to embed some Markdown within the document content. That's easy to do using a `markdownify` block:

```eruby
<%%= markdownify do %>
   ## I'm a header!

   * Yay!
   <%%= "* Nifty!" %>
<%% end %>
```

You can also pass in any string variable as a method argument:

```eruby
<%%= markdownify some_string_var %>
```

Alternatively, you can author a document with a `.md` extension and configure it via `template_engine: erb` to get processed through ERB. (Continue reading for additional information.)

## Extensions and Permalinks

Sometimes you may want to output a file that doesn't end in `.html`. Perhaps you want to create a JSON index of a collection, or a special XML feed. If you have familiarity with other Ruby site generators or frameworks, you might instinctively reach for the solution where you use a double extension, say, `posts.json.erb` to indicate the final extension (`json`) and the template type (`erb`).

Bridgetown doesn't support double extensions but rather provides a couple of alternative mechanisms to specify your template engine of choice. The first option is to set the file's permalink using front matter. Here's an example of `posts.json.erb` using a [custom permalink](/docs/structure/permalinks):

```eruby
---
permalink: /posts.json
---
[
  <%%
    site.posts.docs.each_with_index do |post, index|
      last_item = index == site.posts.docs.length - 1
  %>
    {
      "title": <%%= jsonify post.data[:title].strip %>,
      "url": "<%%= absolute_url post.url %>"<%%= "," unless last_item %>
    }
  <%% end %>
]
```

This ensures the final relative URL will be `/posts.json`. (Of course you can also set the permalink to anything you want, regardless of the filename itself.)

The second option is to switch template engines using front matter or site-wide configuration. That will allow you to write `posts.json` and have it use ERB automatically (instead of the default which is Liquid). [Find out more about choosing template engines here.](/docs/template-engines)

## Link and URL Helpers

The `link_to` and `url_for` helpers let you create anchor tags which will link to any source page/document/static file (or any relative/absolute URL you pass in).

To link to source content, pass in a path to file in your `src` folder that translates to a published URL. For example, if you have a blog post saved at `src/_posts/2020-10-29-my-nifty-article.md`

```eruby
<%%= link_to "Click me!", "_posts/2020-10-29-my-nifty-article.md" %>

<!-- output: -->
<a href="/blog/my-nifty-article">Click me!</a>
```

The `link_to` helper uses `url_for`, so you can use that to get the url directly:

```eruby
<%% article_url = url_for("_posts/2020-10-29-my-nifty-article.md") %>
```

Note that `url_for` is also aliased to `link` in order to provide compatibility with [the link Liquid tag](/docs/liquid/tags#link){:data-no-swup="true"}.

You can pass additional keyword arguments to `link_to` which will be translated to HTML attributes:

```eruby
<%%= link_to "Join our livestream!", "_events/livestream.md", class: "event", data_expire: "2020-11-08" %>

<!-- output: -->
<a href="/events/livestream" class="event" data-expire="2020-11-08">Join our livestream!</a>
```

You can also pass relative or aboslute URLs to `link_to` and they'll just pass-through to the anchor tag without change:

```eruby
<%%= link_to "Visit Bridgetown", "https://www.bridgetownrb.com" %>
```

Finally, if you pass a Ruby object (i.e., it responds to `url`), it will work as you'd expect:

```eruby
<%%= link_to "My last page", @site.pages.last %>

<!-- output: -->
<a href="/this/is/my-last-page">My last page</a>
```

## Capture Helper

If you need to capture a part of your template and store it in a variable for later use, you can use the `capture` helper.

```eruby
<%% test_capturing = capture do %>
  This is how <%%= "#{"cap"}turing" %> works!
<%% end %>

<%%= test_capturing.reverse %>
```

One interesting use case for capturing is you could assign the captured text to a layout data variable. Using memoization, you could calculate an expensive bit of template once and then reuse it either in that layout or in a partial.

Example:

```eruby
<%% # add this code to a layout: %>
<%% layout.data[:save_this_for_later] ||= capture do
  puts "saving this into the layout!"
%>An <%%= "expensive " + "routine" %> to be saved<%% end %>

Some text...

<%%= partial "use_the_saved_variable" %>
```

```eruby
<%% # src/_partials/_use_the_saved_variable.erb %>
Print this: <%%= layout.data[:save_this_for_later] %>
```

Because of the use of the `||=` operator, you'll only see "saving this into the layout!" print to the console once when the site builds even if you use the layout on thousands of pages!

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
<%%= uppercase_string "i'm a string" %>

<!-- output: -->
I'M A STRING
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

```eruby
<%%= lowercase_string "WAY DOWN LOW" %>
```

```Liquid
{{ "WAY DOWN LOW" | lowercase_string }}
```

## Haml and Slim

Bridgetown comes with ERB support out-of-the-box, but you can easily add support for either Haml or Slim by installing our officially supported plugins.

* [`bridgetown-haml`](https://github.com/bridgetownrb/bridgetown-haml){:rel="noopener"}
* [`bridgetown-slim`](https://github.com/bridgetownrb/bridgetown-slim){:rel="noopener"}

All you'd need to do is run `bundle add bridgetown-haml -g bridgetown_plugins` (or `bridgetown-slim`) to install the plugin, and then you can immediately start using `.haml` or `.slim` pages, layouts, and partials in your Bridgetown site.

## Turning off Liquid processing

For pages/documents, Bridgetown will automatically detect if you use Liquid tags (aka `{% %}` or `{{ }}`) and process your file with Liquid even if it's using ERB or another template language (unless you've configured your site such that Liquid is no longer the default template engine). This happens prior to any other conversions, so you can in theory using both Liquid and ERB in the same file.

You can however turn that off with front matter:

```yaml
render_with_liquid: false
```

Or manually specify a template engine:

```yaml
template_engine: slim
```

If you wish to turn off Liquid across a variety of files, you can use [front matter defaults](/docs/configuration/front-matter-defaults) to set `render_with_liquid` to `false` without having to add that to each file's front matter, or you can [switch template engines](/docs/template-engines) for your entire site. It's up to you.
