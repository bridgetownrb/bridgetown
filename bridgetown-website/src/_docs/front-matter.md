---
title: Front Matter
order: 12
top_section: Content
category: front-matter
---

Front matter is a snippet of [YAML](https://yaml.org/) which sits between two
triple-dashed lines at the top of a file. You use front matter to add metadata,
like a title or a description, to files such as pages and posts as well as site
layouts. Front matter can be used in various ways to set configuration options
on a per-file basis, and starting with Bridgetown v0.13, you can even write Ruby
code for dynamic front matter variables.

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

The front matter must be the first thing in the file and must take the form of valid
YAML set between triple-dashed lines. Here is a basic example:

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
front matter of a page or post.

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
            Using <code>none</code> in a post/document will
            produce a file without using a layout file regardless of front matter defaults.
            Using <code>none</code> in a page will cause Bridgetown to attempt to
            use a layout named "none".
          </li>
        </ul>
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

## Ruby Front Matter

For advanced use cases where you wish to generate dynamic values for front matter variables, you can use Ruby Front Matter (new in Bridgetown v0.13). This feature is available for pages, posts, and other documents–as well as layouts for site-wide access to your Ruby return values.

{% rendercontent "docs/note" %}
Prior to v0.17, this required the environment variable `BRIDGETOWN_RUBY_IN_FRONT_MATTER` to be set to `"true"`, otherwise the code would not be executed and would be treated as a raw string.
{% endrendercontent %}

[Here's a blog post with a high-level overview](/feature/supercharge-your-bridgetown-site-with-ruby-front-matter/){:data-no-swup="true"} of what Ruby Front Matter is capable of and why you might want to use it.

To write Ruby code in your front matter, use the special tagged string `!ruby/string:Rb`. Here is an example:

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
