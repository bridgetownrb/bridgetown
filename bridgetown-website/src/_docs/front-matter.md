---
title: Front Matter
order: 12
top_section: Content
category: front-matter
---

Front matter is a snippet of [YAML](https://yaml.org/) or Ruby data which sits at the top of a file between special line delimiters. You can think of front matter as a datastore consisting of one or more key-value pairs (aka a `Hash` in Ruby). You use front matter to add metadata, like a title or a description, to files such as pages and documents as well as site layouts. Front matter can be used in various ways to set configuration options on a per-file basis, and if you need more dynamic handling of variable data, you can write Ruby code for processing as front matter.

{% rendercontent "docs/note", title: "Don't repeat yourself" %}
If you'd like to avoid repeating your frequently used variables
over and over, you can define [front matter defaults](/docs/configuration/front-matter-defaults) for them and only override them where necessary (or not at all). This works
both for predefined and custom variables.
{% endrendercontent %}

{% toc %}

## Using Front Matter

Any file that contains a front matter block will be specially processed by
Bridgetown. Files without front matter are considered [static files](/docs/static_files/)
and are copied verbatim from the source folder to destination during the build
process.

The front matter must be the first thing in the file and must either take the form of valid
YAML set between triple-dashed lines, or one of several Ruby-based formats (more on that below). Here is a basic example:

```yaml
---
layout: post
title: Blogging Like a Hacker
---
```

Between these triple-dashed lines, you can set predefined variables (see below
for a reference) or add custom variables of your own. These variables will
then be available to you to access using Liquid tags both further down in the
file and also in any layouts or components that the file in question relies on.

{% rendercontent "docs/note", title: "Front matter variables are optional" %}
  If you want to use [Liquid tags and variables](/docs/variables/)
  but don’t need anything in your front matter, just leave it empty! The set
  of triple-dashed lines with nothing in between will still get Bridgetown to
  process your file. (This is useful for things like RSS feeds.)
{% endrendercontent %}

## Predefined Global Variables

There are a number of predefined global variables that you can set in the
front matter of a page or document.

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>layout</code></p>
      </td>
      <td>
        <p>

          If set, this specifies the layout file to use. Use the layout file
          name without the file extension. Layout files must be placed in the
          <code>_layouts</code> directory.

        </p>
        <ul>
          <li>
            Using <code>null</code> will produce a file without using a layout
            file. This is overridden if the file is a document and has a
            layout defined in the <a href="{{ '/docs/configuration/front-matter-defaults/' | relative_url }}">
            front matter defaults</a>.
          </li>
          <li>
            Using <code>none</code> will produce a file without using a layout file
            regardless of front matter defaults.
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>template_engine</code></p>
      </td>
      <td>
        <p>
          You can change the <a href="/docs/template-engines">template engine</a> Bridgetown uses to process the file.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>permalink</code></p>
      </td>
      <td>
        <p>

          If you need your URLs to be something other than what is configured by default,
          (for posts, the default is <code>/category/year/month/day/title.html</code>),
          then you can set this variable and it will be used as the final URL.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>published</code></p>
      </td>
      <td>
        <p>
          Set to false if you don’t want a specific page to show up when the
          site is generated.
        </p>
      </td>
    </tr>
  </tbody>
</table>

{% rendercontent "docs/note", title: "Render pages marked as unpublished" %}
  To preview unpublished pages, run `bridgetown serve` or `bridgetown build` with
  the `--unpublished` switch.
{% endrendercontent %}

## Custom Variables

You can set your own front matter variables which become accessible via Liquid. For
instance, if you set a variable called `food`, you can use that in your page:

{% raw %}
```liquid
---
food: Pizza
---

<h1>{{ page.food }}</h1>
```
{% endraw %}

Or if you're using the ERB template engine:

```eruby
---
food: Pad Thai
---

<h1><%= page.data[:food] %></h1>
```

You can also use a document's front matter variables in other places like layouts, and
you can even reference those variables in loops through documents or as part of more
complex queries (see [Liquid filters](/docs/liquid/filters/) for more information).

## Predefined Variables for Posts

For documents in the `posts` collection, these variables are available out-of-the-box:

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>date</code></p>
      </td>
      <td>
        <p>
          Specifying a date variable overrides the date from the filename of the post.
          This can be used to ensure correct sorting of posts. A date is specified in the
          format <code>YYYY-MM-DD HH:MM:SS +/-TTTT</code>; hours, minutes, seconds, and
          timezone offset are optional.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>category</code></p>
        <p><code>categories</code></p>
      </td>
      <td>
        <p>

          You can specify one or more categories that the post belongs to, and then you can
          use that to filter posts in various ways or use the "slugified" version of the
          category name to adjust the permalink for a post. Categories (plural key) can be
          specified as a <a
          href="https://en.wikipedia.org/wiki/YAML#Basic_components" rel="noopener">YAML list</a> or a
          space-separated string.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>tags</code></p>
      </td>
      <td>
        <p>
          Similar to categories, one or multiple tags can be added to a post as a flexible
          method of building a lightweight content <a href="https://en.wikipedia.org/wiki/Taxonomy" rel="noopener">taxonomy</a>.
          As with categories, tags can be specified as a <a
          href="https://en.wikipedia.org/wiki/YAML#Basic_components" rel="noopener">YAML list</a> or a
          space-separated string.
        </p>
      </td>
    </tr>
  </tbody>
</table>

## Advanced Front Matter Data Structures

YAML allows for pretty sophisticated methods of structuring data, for example representing arrays or hashes (key/value pairs). You can also write out longer multi-line strings like so:

```yaml
---
description: |
  I am a multiple line
  string value that can
  go on and on.
---
```

For reference, [here's a side-by-side comparison](https://yaml.org/YAML_for_ruby.html) of YAML data structures and their equivalents in Ruby.

{% rendercontent "docs/note", type: "warning", title: "UTF-8 Character Encoding Warning" %}
If you use UTF-8 encoding, make sure that no `BOM` header characters exist in your files or
you may encounter build errors.
{% endrendercontent %}

## The Power of Ruby, in Front Matter

For advanced use cases where you wish to generate dynamic values for front matter variables, you can use Ruby Front Matter (hereafter named rbfm). (Requires Bridgetown v0.21 or greater. Only applies to sites using the [Resource content engine](/docs/resources)—otherwise read the Legacy Format of Ruby Front Matter section below.)

Any valid Ruby code is allowed in rbfm as long as it returns a `Hash`—or an object which `respond_to?(:to_h)`. There are several different ways you can define rbfm at the top of your file. This is so syntax highlighting will work in various different template scenarios.

For Markdown files, you can use backticks or tildes plus the term `ruby` to take advantage of GFM (GitHub-flavored Markdown) syntax highlighting.

~~~md
```ruby
{
  layout: :page,
  title: "About"
}
```

I'm a **Markdown** file.
~~~

or

```md
~~~ruby
{
  layout: :page,
  title: "About"
}
~~~

I'm a **Markdown** file.
```

For ERB or Serbea files, you can use `---<%` / `%>---` or `---{%` / `%}---` delimeters respectively. (You can substitute `~` instead of `-` if you prefer.)

For all-Ruby files, you can use `---ruby` / `---` or `###ruby` / `###` delimeters.

However you define your rbfm, bear in mind that the front matter code is executed _prior_ to any processing of the template file itself and within a different context. (rbfm will be executed initially within either `Bridgetown::Model::RepoOrigin` or `Bridgetown::Layout`.)

Thankfully, there is a solution for when you want a front matter variable resolved within the execution context of a resource (aka `Bridgetown::Resource::Base`): use a lambda. Any lambda (or proc in general) will be resolved at the time a resource has been fully initialized. A good use case for this would be to define a custom permalink based on other front matter variables. For example:

```md
~~~ruby
{
  layout: :page,
  segments: ["custom", "permalink"],
  title: "About Us",
  permalink: -> { "#{data.segments.join("/")}/#{Bridgetown::Utils.slugify(data.title)}" }
}
~~~

This will now show up for the path: /custom/permalink/about-us
```

Besides using a simple `Hash`, you can also use the handy `front_matter` DSL. Any valid method call made directly in the block will translate to a front matter key. Let's rewrite the above example:

```md
~~~ruby
front_matter do
  layout :page

  url_segments = ["custom"]
  url_segments << "permalink"
  segments url_segments

  title "About Us"
  permalink -> { "#{data.segments.join("/")}/#{Bridgetown::Utils.slugify(data.title)}" }
end
~~~

This will now show up for the path: /custom/permalink/about-us
```

As you can see, literally any valid Ruby code has the potential to be transformed into front matter. The sky's the limit!

## Legacy Format of Ruby Front Matter

{% rendercontent "docs/note", type: "warning" %}
Embedding Ruby code within YAML is deprecated and will be removed by the release of Bridgetown 1.0.
{% endrendercontent %}

This feature is available for pages, posts, and other documents–as well as layouts for site-wide access to your Ruby return values. To write Ruby code in your front matter, use the special tagged string `!ruby/string:Rb`. Here is an example:

{% raw %}
```liquid
---
title: I'm a page
permalink: /ruby-demo
calculation: !ruby/string:Rb |
  [2 * 4, 5 + 2].min
---

Title: {{ page.title }}
Calc Result: {{ page.calculation }}
```
{% endraw %}

In the final page output rendered by Liquid, the value of the `calculation` variable will be the return value of the Ruby code.

You can write any Ruby code into a front matter variable. However, if you need to write a lengthy block of code, or write code that is easily customizable or reusable in multiple contexts, [we still recommended you write a Bridgetown plugin](/docs/plugins/)—either in the `plugins` folder in your site repo or as a separate Gem-based plugin.

Depending on if your Ruby code is added to a document or a layout, certain Ruby objects are provided for your use.

For **layouts**, you can access: `site`, `layout`, and `data`.

For **documents**, you can access: `site`, `page` or `document` (they are equivalent), `renderer`, and `data`.

Documentation on the internal Ruby API for Bridgetown is forthcoming, but meanwhile the easiest way to debug the code you write is to run `bridgetown console` and interact with the API there, then copy working code into your Ruby Front Matter.

{% rendercontent "docs/note", type: "warning" %}
For security reasons, please _do not allow_ untrusted content into your repository to be executed in an unsafe environment (aka outside of a Docker container or similar). Just like with custom plugins, a malicious content contributor could potentially introduce harmful code into your site and thus any computer system used to build that site. Enable Ruby Front Matter _only_ if you feel confident in your ability to control and monitor all on-going updates to repository files and data.
{% endrendercontent %}
