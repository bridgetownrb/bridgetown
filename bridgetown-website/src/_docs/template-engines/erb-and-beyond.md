---
title: ERB and Beyond
order: 0
top_section: Designing Your Site
category: template-engines
template_engine: erb
---

Bridgetown's implementation language, Ruby, has a rich history of providing [ERB (Embedded RuBy)](https://docs.ruby-lang.org/en/2.7.0/ERB.html) for templates and view layers across a wide variety of tools and frameworks. Other Ruby-based template languages such as [Haml](https://haml.info), [Slim](http://slim-lang.com), and [Serbea](https://www.serbea.dev) garner enthusiastic usage as well.

Bridgetown makes it easy to add both ERB-based and Serbea-based templates and components to any site. In additional, there are plugins you can easily install for Haml and Slim support. Under the hood, Bridgetown uses the [Tilt gem](https://github.com/rtomayko/tilt) to load and process these Ruby templates.

<%= render Note.new do %>
  Interested in switching your entire site to use ERB or Serbea by default? [It's possible to do that with just a simple configuration change.](/docs/template-engines#site-wide-configuration)
<% end %>

<%= toc %>

## Usage

For ERB, simply define a page/document with an `.erb` extension, rather than `.html`. You'll still need to add front matter to the top of the file (or at the very least two lines of triple dashes `---`) for the file to get processed. In the Ruby code you embed, you'll be interacting with the underlying Ruby API for Bridgetown objects (aka `Bridgetown::Page`, `Bridgetown::Site`, etc.). Here's an example:

```eruby
---
title: I'm a page!
---

<h1><%%= resource.data.title %></h1>

<p>Welcome to <%%= Bridgetown.name.to_s %>!</p>

<footer>Authored by <%%= site.data.authors.first.name %></footer>
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

You can easily loop through resources in a collection:

```eruby
<%% collections.posts.resources.each do |post| %>
  <li><a href="<%%= post.relative_url %>"><%%= post.data.title %></a></li>
<%% end %>
```

Or using the [paginator](/docs/content/pagination), along with the `link_to` helper:

```eruby
<%% paginator.resources.each do |post| %>
  <li><%%= link_to post.data.title, post %></li>
<%% end %>
```

### Serbea

Serbea is a "superset" of ERB which provides the same benefits as ERB but uses curly braces like Liquid `{% %}` or `{{ }}` and adds support for filters and render directives. Use the file extension `.serb`. Here's an example of the above ERB code rewritten in Serbea:

```serb
{% collections.posts.resources.each do |post| %}
  <li><a href="{{ post.relative_url }}">{{ post.data.title }}</a></li>
{% end %}

----

{% paginator.resources.each do |post| %}
  <li>{{ post.data.title | link_to: post }}</li>
{% end %}
```

Notice this is using the Liquid-like filter syntax for `link_to`. You can use this kind of syntax with _any_ helpers available in all Ruby templates, as well as methods on objects themselves. Examples:

```serb
{{ resource.data.description | markdownify }}

{{ resource.data.title | titleize }}

{{ resource.data.tags | array_to_sentence_string: "or" }}

{{ resource.data.upcase_me | upcase }} <!-- in this case upcase is a method on the String object itself! -->
```

(Under the hood, a Ruby method's first argument will be supplied with the value of the left-side of the pipe `|` operator, and subsequent arguments continue after that as you write the filter syntax.)

For Serbea code samples in Markdown, use the `serb` tag. And like ERB, you can escape using two percent signs:

~~~md
Here's·my·**Markdown**·file.

```serb
And·my·{%%= "ERB·code·sample" %}
```
~~~

Serbea also provides a `raw` helper just like Liquid for escaping Serbea code:

```serb

Process me! {% do_something %}

Don't process me! {% raw %}{% do_something %}{% endraw %}
```

There's a [VS Code extension available for Serbea](https://marketplace.visualstudio.com/items?itemName=whitefusion.serbea) which includes syntax highlighting as well as commands to convert selected ERB syntax to Serbea, and even a Serbea + Markdown highlighter.

For details on HTML output safety, see below (Serbea and ERB differ slightly on how escaping is accomplished).

## Dot Access Hashes

Data hashes support standard hash key access, but most of the time you can use "dot access" instead for a more familar look. For example:

```eruby
<%%= post.data.title %> (but <%%= post.data[:title] %> or <%%= post.data["title"] %> also work)

<%%= resource.data.author %>

<%%= site.data.authors.lakshmi.twitter.handle %>

<%% # You can freely mix hash access and dot access: %>

<%%= site.data.authors[resource.data.author].github %>
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

<h1><%%= resource.data.title %></h1>

<p>Welcome to <%%= Bridgetown.name %>!</p>

<%%= render "author_footer" %>
```

You can also pass variables to partials using either a `locals` hash or as keyword arguments:

```eruby
<%%= render "some/partial", key: "value", another_key: 123 %>

<%%= render "some/partial", locals: { key: "value", another_key: 123 } %>
```

As an alternative to passing the partial filename as the first argument, you can supply a `template` keyword argument instead. This makes it easier to pass all arguments via a separate hash:

```eruby
<%% options = { template: "mypartial", title: "Hello!" } %>
<%%= partial **options %>
```

Partials also support capture blocks, which can then be referenced via the `content` local variable within the partial.

## Rendering Ruby Components

For better encapsulation and reuse of Ruby-based templates as part of a "design system" for your site, we encourage you to write Ruby components using either `Bridgetown::Component` or GitHub's ViewComponent library. [Check out the documentation and code examples here](/docs/components/ruby).

## Liquid Filters, Tags, and Components

Bridgetown includes access to some helpful [Liquid filters](/docs/liquid/filters) as helpers within your ERB templates:

```eruby
<!-- July 9th, 2020 -->
<%%= date_to_string site.time, "ordinal" %>
```

These helpers are actually methods of the `helper` object which is an instance of `Bridgetown::RubyTemplateView::Helpers`.

A few Liquid tags are also available as helpers too, such as [`class_map`](/docs/liquid/tags#class-map-tag){:data-no-swup="true"} and [`webpack_path`](/docs/frontend-assets#linking-to-the-output-bundles){:data-no-swup="true"}.

In addition to using Liquid helpers, you can also render [Liquid components](/docs/components/liquid) from within your ERB templates via the `liquid_render` helper.

```eruby
<p>
  Rendering a component:
  <%%= liquid_render "test_component", param: "Liquid FTW!" %>
</p>
```

```html
<!-- src/_components/test_component.liquid -->
<p>{{ param }}</p>
```

## Layouts

You can add an `.erb` layout and use it in much the same way as a Liquid-based layout. You can freely mix'n'match ERB layouts with Liquid-based documents and Liquid-based layouts with ERB documents.

`src/_layouts/testing.erb`

```eruby
---
layout: default
somevalue: 123
---

<h1><%%= resource.data.title %></h1>

<main>An ERB layout! <%%= layout.name %> / somevalue: <%%= layout.data.somevalue %></main>

<%%= yield %>
```

`src/page.html`
```Liquid
---
layout: testing
---

A standard Liquid page. {{ resource.data.layout }}
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

Bridgetown doesn't support double extensions but rather provides a couple of alternative mechanisms to specify your template engine of choice. The first option is to set the file's permalink using front matter. Here's an example of `posts.json.erb` using a [custom permalink](/docs/content/permalinks):

```eruby
---
permalink: /posts.json
---
[
  <%%
    collections.posts.resources.each_with_index do |post, index|
      last_item = index == collections.posts.resources.length - 1
  %>
    {
      "title": <%%= jsonify post.data.title.strip %>,
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

In order to simplify more complex lists of HTML attributes you may also pass a hash as the value of one of the keyword arguments.  This will convert all pairs in the hash into HTML attributes and prepend each key in the hash with the keyword argument:

```eruby
<%%= link_to "Join our livestream!", "_events/livestream.md", data: { controller: "testable", action: "testable#test" } %>

<!-- output: -->
<a href="/events/livestream" data-controller="testable" data-action="testable#test">Join our livestream!</a>
```

`link_to` uses [`attributes_from_options`](#attributes_from_options) under the hood to handle this converstion.

You can also pass relative or aboslute URLs to `link_to` and they'll just pass-through to the anchor tag without change:

```eruby
<%%= link_to "Visit Bridgetown", "https://www.bridgetownrb.com" %>
```

Finally, if you pass a Ruby object (i.e., it responds to `url`), it will work as you'd expect:

```eruby
<%%= link_to "My last page", collections.pages.resources.last %>

<!-- output: -->
<a href="/this/is/my-last-page">My last page</a>
```

## Other HTML Helpers

### attributes_from_options
`attributes_from_options` allows you to pass a hash and have it converted to a string of HTML attributes:
```eruby
<p <%%= attributes_from_options({ class: "my-class", id: "some-id" }) %>>Hello, World!</p>

<!-- output: -->
<p class="my-class" id="some-id">Hello, World!</p>
```
`attributes_from_options` also allows for any value of the passed hash to itself be a hash. This will result in individual attributes being created from each pair in the hash. When doing this, the key the hash was paired with will be prepended to each attribute name:
```eruby
<button <%%= attributes_from_options({ data: { controller: "clickable", action: "click->clickable#test" } }) %>>Click Me!</button>

<!-- output: -->
<button data-controller="clickable" data-action="click->clickable#test">Click Me!</button>
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

## Escaping and HTML Safety

The ERB template engine uses a safe output buffer—[the same one used in Rails](https://guides.rubyonrails.org/active_support_core_extensions.html#output-safety).

That means that you'll sometimes find that if you simply output a front matter variable or some other string value that contains HTML tags and entities, the string will be "escaped" so that the actual angle brackets and so forth are displayed in the website content (rather than being interpreted as valid HTML tags).

Often that's the right call for [security purposes to avoid XSS attacks](https://guides.rubyonrails.org/security.html#cross-site-scripting-xss) or to bypass potential markup errors. However, to explicitly mark a string as safe, you can use the `html_safe` method. Bridgetown provides the `raw` or `safe` helpers as well. You can also use a double-equals sign to bypass escaping entirely.

```erb
<%%= some_value.html_safe %>
<!-- or -->
<%%= raw some_value %>
<!-- or -->
<%%= safe some_value %>
<-- or -->
<%%== some_value %>
```

Note that using `html_safe` directly _requires_ the value to be a string already. If you use the `raw`/`safe` helpers, it will first perform `to_s` automatically. Also bear in mind that `<%%= yield %>` or `<%%= content %>` or rendering components/partials won't perform escaping on the rendered template output. (This is for obvious reasons—otherwise you'd get a visual mess of escaped HTML tags.)

If you find a particular use case where escaping occurs (or doesn't occur) in an unexpected manner, [please file a bug report in the Bridgetown GitHub repo](https://github.com/bridgetownrb/bridgetown/issues/new?assignees=&labels=bug&template=bug_report.md&title=).

### When Using Serbea

Serbea only escapes values by default when using the double-braces syntax `{{ }}`. When using `{%= %}`, escaping does _not_ occur by default.

```serb
str = "<p>Escape me!</p>"

{{ str }} <!-- output: &lt;p&gt;Escape me!&lt;/p&gt; -->
{%= str %} <!-- output: <p>Escape me!</p> -->
```

To explicitly escape a value when using percent signs, use the `escape` or `h` helper. To explicitly mark a value as safe when using double-braces, use the `safe` or `raw` filter:

```serb
str = "<p>Escape me!</p>"

{{ str | safe }} <!-- output: <p>Escape me!</p> -->
{%= escape(str) %} <!-- output: &lt;p&gt;Escape me!&lt;/p&gt; -->
```

## Haml and Slim

Bridgetown comes with ERB support out-of-the-box, but you can easily add support for either Haml or Slim by installing our officially supported plugins.

* [`bridgetown-haml`](https://github.com/bridgetownrb/bridgetown-haml){:rel="noopener"}
* [`bridgetown-slim`](https://github.com/bridgetownrb/bridgetown-slim){:rel="noopener"}

All you'd need to do is run `bundle add bridgetown-haml -g bridgetown_plugins` (or `bridgetown-slim`) to install the plugin, and then you can immediately start using `.haml` or `.slim` pages, layouts, partials, and [components](/docs/components/ruby) in your Bridgetown site.

## Serbea

Serbea combines the best ideas from “brace-style” template languages such as Liquid, Nunjucks, Twig, Jinja, Mustache, etc.—and applies them to the world of ERB. In addition to Bridgetown sites, you can use Serbea in Rails applications or pretty much any Ruby scenario you could imagine.

```
bundle add serbea -g bridgetown_plugins
```

[Find out more about using Serbea in Bridgetown here.](https://www.serbea.dev/#bridgetown-support)
