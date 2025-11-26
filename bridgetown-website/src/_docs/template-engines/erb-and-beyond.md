---
title: Ruby-Based Template Types
order: 0
top_section: Designing Your Site
category: template-engines
template_engine: erb
---

Bridgetown's implementation language, Ruby, has a rich history of providing "Embedded RuBy" aka ERB templates and view layers across a wide variety of tools and frameworks. In addition to ERB, Bridgetown provides two additional Ruby-based template types: [Serbea](https://www.serbea.dev) (a superset of ERB), and **Streamlined** (which is a form of pure Ruby code).

<%= render Note.new do %>
  New Bridgetown sites are configured with ERB by default. But you can start off a project with another engine like Serbea or Liquid [with a configuration change](/docs/template-engines#site-wide-configuration), and you can use multiple template types in a single project.

  Note that Streamlined itself can't be specified as a "template engine" because it's not string-based (so you couldn't "embed" Streamlined code in, say, a Markdown file). Streamlined works well as an _augmentation_ to a site configured with either ERB or Serbea.
<% end %>

<%= render Note.new do %>
  Under the hood, Bridgetown uses the [Tilt gem](https://github.com/jeremyevans/tilt) to load and process ERB & Serbea. Plugin authors can leverage Tilt to add support for other template types.
<% end %>

<%= toc %>

## ERB Basics

For ERB, resources are typically saved with an `.erb` extension. Other extensions like `.html` or `.md` will be processed through ERB unless another template engine is configured. To embed Ruby code in your template, use the delimiters `<%% %>` for code blocks and `<%%= %>` for output expressions.

As with all resources, you'll need to add front matter to the top of the file (or at the very least two lines of triple dashes `---`) for the file to get processed. In the Ruby code you embed, you'll be interacting with the underlying Ruby API for Bridgetown objects (aka `Bridgetown::Page`, `Bridgetown::Site`, etc.). Here's an example:

```eruby
---
title: I'm a page!
---

<h1><%%= data.title %></h1>

<p>Welcome to <%%= Bridgetown.name.to_s %>!</p>

<footer>Authored by <%%= site.data.authors.first.name %></footer>
```

Front matter is accessible via the `data` method on pages, posts, layouts, and other documents. The resource itself is available via `resource`. Site config values are accessible via the `site.config` method, and loaded data files via `site.data` as you would expect.

<%= render Note.new do %>
  In addition to `site`, you can also access the `site_drop` object which will provide similar access to various data and config values similar to the `site` variable in Liquid.
<% end %>

If you need to escape an ERB tag (to use it in a code sample for example), use two percent signs:

~~~md
Here's my **Markdown** file.

```erb
And my <%%%= "ERB code sample" %>
```
~~~

You can easily loop through resources in a collection:

```eruby
<%% collections.posts.each do |post| %>
  <li><a href="<%%= post.relative_url %>"><%%= post.data.title %></a></li>
<%% end %>
```

Or using the [paginator](/docs/content/pagination), along with the `link_to` helper:

```eruby
<%% paginator.each do |post| %>
  <li><%%= link_to post.data.title, post %></li>
<%% end %>
```

### Serbea

Serbea is a "superset" of ERB which provides the same benefits as ERB but uses curly braces: `{% %}` or `{{ }}` and adds support for filters and render directives. Use the file extension `.serb`. Here's an example of the above ERB code rewritten in Serbea:

```serb
{% collections.posts.each do |post| %}
  <li><a href="{{ post.relative_url }}">{{ post.data.title }}</a></li>
{% end %}

----

{% paginator.each do |post| %}
  <li>{{ post.data.title | link_to: post }}</li>
{% end %}
```

Notice this is using the filter syntax similar to Liquid for `link_to`. You can use this kind of syntax with _any_ helpers available in all Ruby templates, as well as methods on objects themselves. Examples:

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

Data hashes support standard hash key access, but most of the time you can use "dot access" instead for a more familiar look. For example:

```eruby
<%%= post.data.title %> (but <%%= post.data[:title] %> or <%%= post.data["title"] %> also work)

<%%= resource.data.author %>

<%%= site.data.authors.lakshmi.mastodon.handle %>

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

<h1><%%= data.title %></h1>

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

For better encapsulation and reuse of Ruby-based templates as part of a "design system" for your site, we encourage you to write Ruby components using `Bridgetown::Component`. [Check out the documentation and code examples here](/docs/components/ruby).

## Liquid Filters, Tags, and Components

Bridgetown includes access to some helpful [Liquid filters](/docs/liquid/filters) as helpers within your ERB templates:

```eruby
<!-- July 9th, 2020 -->
<%%= date_to_string site.time, "ordinal" %>
```

These helpers are actually methods of the `helper` object which is an instance of `Bridgetown::TemplateView::Helpers`.

A few Liquid tags are also available as helpers too, such as [`class_map`](/docs/liquid/tags#class-map-tag){:data-no-swup="true"} and [`asset_path`](/docs/frontend-assets#linking-to-the-output-bundles){:data-no-swup="true"}.

In addition to using Liquid helpers, you can also render [Liquid components](/docs/components/liquid) from within your ERB templates via the `liquid_render` helper.

```eruby
<p>
  Rendering a component:
  <%%= liquid_render "test_component", param: "Liquid FTW!" %>
</p>
```

```liquid
<!-- src/_components/test_component.liquid -->
<p>{{ param }}</p>
```

## Layouts

You can add an `.erb` layout to the `_layouts` folder for use by resources even other layouts. You can freely mix 'n' match ERB layouts with Liquid-based documents and Liquid-based layouts with ERB documents.

`src/_layouts/testing.erb`

```eruby
---
layout: default
somevalue: 123
---

<h1><%%= data.title %></h1>

<main>An ERB layout! <%%= layout.name %> / somevalue: <%%= layout.data.somevalue %></main>

<%%= yield %>
```

`src/page.html`
```liquid
---
layout: testing
---

A standard Liquid page. {{ resource.data.layout }}
```

If your layout or a layout partial needs to load your frontend assets, use the `asset_path` helper:

```eruby
<link rel="stylesheet" href="<%%= asset_path :css %>" />
<script src="<%%= asset_path :js %>" defer></script>
```

## Markdown

To embed Markdown within an ERB template, you can use a `markdownify` block:

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

## Extensions and Permalinks

Sometimes you may want to output a file that doesn't end in `.html` when published. Perhaps you want to create a JSON index of a collection, or a special XML feed. If you have familiarity with other Ruby site generators or frameworks, you might instinctively reach for the solution where you use a double extension, say, `posts.json.erb` to indicate the final extension (`json`) and the template type (`erb`).

Bridgetown doesn't support double extensions but rather provides a couple of alternative mechanisms to specify your template engine of choice. The first option is to utilize the default ERB processing, so your `posts.json` file will be processed through ERB automatically as long as it includes the triple-dashes front matter.

The second option is to set the file's permalink using front matter. Here's an example of a `posts.erb` file using a [custom permalink](/docs/content/permalinks):

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

`link_to` uses [`html_attributes`](#html_attributes) under the hood to handle this conversation.

You can also pass relative or absolute URLs to `link_to` and they'll pass-through to the anchor tag without change:

```eruby
<%%= link_to "Visit Bridgetown", "https://www.bridgetownrb.com" %>
```

Finally, if you pass a Ruby object (i.e., it responds to `url`), it will work as you'd expect:

```eruby
<%%= link_to "My last page", collections.pages.resources.last %>

<!-- output: -->
<a href="/this/is/my-last-page">My last page</a>
```

## Slotted Content

You can contain portions of content in a template file (whether for pages, layouts, or another resources) within "slots". These content slots can then be rendered higher up the rendering pipeline. For example, a resource can define a slot, and its layout can render it. Or a layout itself can define a slot and its parent layout can render it. You can render slots within partials as well.

Bridgetown's [Ruby components](/docs/components/ruby#slotted-content) also has its own slotting mechanism.

Here's an example of using slots in ERB templates to relocate page-specific styles up to the HTML `<head>`.

In your `src/_partials/head.erb` file, append the following:

```erb
<%%= slotted :html_head %>
```

Then on one of your ERB pages, try adding something like:

```erb
<%% slot :html_head do %>
  <style>
    h1 {
      color: navy;
    }
  </style>
<%% end %>
```

You'll then be able to verify that the new style tag only gets rendered out in `<head>` for the particular page where the slot is provided.

Slotted content will automatically adhere to the format of the context where `slot` is called. In other words, if you're in a Markdown file, the slotted content will also be converted from Markdown to HTML. (Additional converter plugins will need to opt-in to support this feature.) To disable this functionality, pass `transform: false`.

The `slotted` helper can also provide default content should the slot not already be defined:

```erb
<%%= slotted :aside do %>
  <p>This only displays if there's no "aside" slot defined.</p>
<%% end %>
```

Multiple captures using the same slot name will be cumulative. The above `aside` slot could be appended to by calling `slot :aside` multiple times. If you wish to change this behavior, you can pass `replace: true` as a keyword argument to `slot` to clear any previous slot content. _Use with extreme caution!_

For more control over slot content, you can use the `pre_render` and `post_render` hooks. Builders can register hooks to transform slots in specific ways based on their name or context:

```rb
class Builders::BeamMeUpSlotty < SiteBuilder
  def build
    hook :slots, :pre_render do |slot|
      slot.content.upcase! if slot.name == "upcase_me"
    end
  end
end
```

Within the hook, you can call `slot.context` to access the definition context for that slot (a resource, a layout, etc.).

<%= render Note.new do %>
  Both `slot` and `slotted` accept an argument instead of a block for content. So you could call `<%% slot :slotname, "Here's some content" %>` rather than supplying a block, or even pass in something like front matter data!
<% end %>

<%= render Note.new(type: :warning) do %>
  Don't let the naming fool you…Bridgetown's slotted content feature is not related to the concept of slots in custom elements and shadow DOM (aka web components). But there are some surface-level similarities. Many view-related frameworks provide some notion of slots (perhaps called something else like content or layout blocks), as it's helpful to be able to render named "child" content within "parent" views. If you're looking for information on using actual HTML slots, check out our new [Declarative Shadow DOM documentation](/docs/content/dsd).
<% end %>

## Other HTML Helpers

### `html_attributes`

`html_attributes` is a helper provided by Streamlined, but you can use it in any Ruby template type. It allows you to pass a hash and have it converted to a string of HTML attributes:
```eruby
<p <%%= html_attributes({ class: "my-class", id: "some-id" }) %>>Hello, World!</p>

<!-- output: -->
<p class="my-class" id="some-id">Hello, World!</p>
```
`html_attributes` also allows for any value of the passed hash to itself be a hash. This will result in individual attributes being created from each pair in the hash. When doing this, the key the hash was paired with will be prepended to each attribute name:
```eruby
<button <%%= html_attributes({ data: { controller: "clickable", action: "click->clickable#test" } }) %>>Click Me!</button>

<!-- output: -->
<button data-controller="clickable" data-action="click->clickable#test">Click Me!</button>
```

### `capture`

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

If you'd like to add your own custom template helpers, you can use the `helper` <abbr title="Domain-Specific Language">DSL</abbr> within builder plugins. [Read this documentation to learn more](/docs/plugins/helpers).

Alternatively, you could open up the `Helpers` class and define additional methods:

```ruby
# plugins/site_builder.rb

Bridgetown::TemplateView::Helpers.class_eval do
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
Bridgetown::TemplateView::Helpers.include MyFilters
```

And at the call site:

```eruby
<%%= lowercase_string "WAY DOWN LOW" %>
```

```liquid
{{ "WAY DOWN LOW" | lowercase_string }}
```

## Escaping and HTML Safety

The ERB template engine uses a safe output buffer—[the same one used in Rails](https://guides.rubyonrails.org/active_support_core_extensions.html#output-safety).

That means that you'll sometimes find that if you output a front matter variable or some other string value that contains HTML tags and entities, the string will be "escaped" so that the actual angle brackets and so forth are displayed in the website content (rather than being interpreted as valid HTML tags).

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

## Streamlined

Streamlined is a new Ruby template type introduced in Bridgetown 2.0. It allow you to embed HTML templates in pure Ruby code using "squiggly heredocs" along with a set of helpers to ensure output safety (proper escaping) and easier interplay between HTML markup and Ruby code. And on average it executes at 1.5x the speed of ERB, making it a good performance choice for large builds.

You can use Streamlined directly in resources saved as pure Ruby (`.rb`), as well as in Bridgetown components. Here's an example of what that looks like:

```ruby
class SectionComponent < Bridgetown::Component
  def initialize(variant:, heading:, **options)
    @variant, @heading, @options = variant, heading, options
  end

  def heading
    <<~HTML
      <h3>#{text -> { @heading }}</h3>
    HTML
  end

  def template
    html -> { <<~HTML
      <section #{html_attributes(variant:, **@options)}>
        #{html -> { heading }}
        <section-body>
          #{html -> { content }}
        </section-body>
      </section>
    HTML
    }
  end
end
```

A few things going on here:

* The `template` method is a standard part of Bridgetown's component system, and here it's being leveraged to render HTML via Streamlined.
* The `html` method's only argument is a stabby lambda (`->`) which in term contains a squiggly heredoc. (_Isn't Ruby terminology fun?_ 😅)
* Within the heredoc, there's a use of the `html_attributes` helper to convert keyword arguments/hashes into HTML attributes, along with additional embeds of Ruby utilizing `html`.
* On top of that, we're able to break our overall template up by defining a "partial" elsewhere (the `heading` method). Calling out to other Ruby methods to incrementally build up HTML markup is a key feature of Streamlined, and offers a DX reminiscent of JavaScript's tagged template literals or JSX.
* The `text` method escapes all values unless they've been explicitly marked as "HTML safe", whereas `html` simply outputs values without preemptive escaping. This requires the template author to think clearly about escaping rules. Default to always using `text` unless you know you're outputting vetted HTML code.

Beyond these patterns, Streamlined has another couple tricks up its sleeve. You can break up template code into multiple `render` passes and also render external components:

```ruby
def template
  render html -> { <<~HTML
    <p>I am HTML markup.</p>
  HTML
  }

  render AnotherComponent.new if @should_render_this

  render html ->{ <<~HTML
    <p>I am more HTML markup.</p>
  HTML
  }
end
```

You can even embed rendering logic inside of `render` blocks:

```ruby
def template
  render html -> { <<~HTML
    <p>I am HTML markup.</p>
  HTML
  }

  render do
    render AnotherComponent.new

    render html ->{ <<~HTML
      <p>I am more HTML markup.</p>
    HTML
    }
  end if @should_render_more_stuff
end
```

Rendering blocks can be nested as well. It's all part of allowing your markup generation to become more modular.

Loop over an array or hash within a heredoc with the `html_map` helper:

```ruby
def template
  html -> { <<~HTML
    <ul>#{
      html_map(@items) do |item|
        <<~HTML
          <li>#{text -> { item }}</li>
        HTML
      end
    }</ul>
  HTML
  }
end
```

<%= render Note.new(type: :warning) do %>
  While Ruby heredocs can use any uppercase text as delimiters, Streamlined requires you to use `HTML`. It's helpful for syntax highlighting in many code editors, and it's also relevant to linting as explained below.
<% end %>

### Enforcing Streamlined helpers using Rubocop

Streamlined provides a Rubocop linter to make sure template authors are utilizing the `text`, `html`, etc. helpers in HTML heredocs, as well as aid with other aspects of your Bridgetown project's Ruby code.

When you install [https://github.com/bridgetownrb/rubocop-bridgetown](https://github.com/bridgetownrb/rubocop-bridgetown), it will automatically detect any heredoc starting with `<<~HTML` and warn you if you aren't utilizing the Streamlined helpers. This will ensure you don't accidentally output raw HTML (a potential security risk) unless you really mean it.

<%= render Note.new do %>
**Q:** Why does Streamlined rely on heredocs which are actually just strings? Why doesn't Streamlined use a special Ruby DSL for generating HTML similar to other tools like Phlex, Papercraft, or Arbre?

**A:** Many of us prefer writing HTML syntax—and beyond that, the value of using a template system which is fully compatible with the vast ecosystem of HTML on the web cannot be overstated. Also as mentioned previously, Streamlined represents an effort to approximate JavaScript's "tagged template literals" in Ruby—an experience already appealing to many frontend developers.
<% end %>

## Universal Rendering

New in Bridgetown 2.1, you have the ability to render partials in template languages other than the one calling the render function. For example, in an ERB page layout you could render a Serbea partial. Or in a Markdown resource with a site configured to use Serbea by default, you could render a pure Ruby partial.

In addition, you can render both partials and components outside of any view context by calling the `render` class method of `TemplateView`. For instance, you could pull up a Bridgetown console and type in the following:

```ruby
Bridgetown::TemplateView.render("path/to/partial", my_var: "it works!")
# or:
Bridgetown::TemplateView.render(MyRubyComponent.new(param1: 123))
```

Partials & components rendered in this manner use a "virtual" resource under-the-hood as part of the view context. If you need to provide front matter data to that resource in order for a partial or component to render as desired, use `new_with_data`:

```ruby
Bridgetown::TemplateView.new_with_data(title: "Here's a title!").render("path/to/partial")
```

You can also provide a virtual path for use by URL helpers:

```ruby
Bridgetown::TemplateView.new_with_data("path/to/page", title: "Page title", description: "...")
```
