---
title: Front Matter
order: 12
top_section: Content
category: front-matter
---

Any file that contains a [YAML](https://yaml.org/) front matter block will be
processed by Bridgetown as a special file. The front matter must be the first thing
in the file and must take the form of valid YAML set between triple-dashed
lines. Here is a basic example:

```yaml
---
layout: post
title: Blogging Like a Hacker
---
```

Between these triple-dashed lines, you can set predefined variables (see below
for a reference) or even create custom ones of your own. These variables will
then be available to you to access using Liquid tags both further down in the
file and also in any layouts or includes that the page or post in question
relies on.

<div class="note warning">
  <h5>UTF-8 Character Encoding Warning</h5>
  <p>
    If you use UTF-8 encoding, make sure that no <code>BOM</code> header
    characters exist in your files or very, very bad things will happen to
    Bridgetown. This is especially relevant if you’re running
    <a href="{{ '/docs/installation/windows/' | relative_url }}">Bridgetown on Windows</a>.
  </p>
</div>

<div class="note">
  <h5>Front Matter Variables Are Optional</h5>
  <p>
    If you want to use <a href="{{ '/docs/variables/' | relative_url }}">Liquid tags and variables</a>
    but don’t need anything in your front matter, just leave it empty! The set
    of triple-dashed lines with nothing in between will still get Bridgetown to
    process your file. (This is useful for things like RSS feeds!)
  </p>
</div>

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
            file. This is overridden if the file is a post/document and has a
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

          If you need your processed blog post URLs to be something other than
          the site-wide style (default <code>/year/month/day/title.html</code>), then you can set
          this variable and it will be used as the final URL.

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

<div class="note">
  <h5>Render Posts Marked As Unpublished</h5>
  <p markdown="1">
    To preview unpublished pages, run `bridgetown serve` or `bridgetown build`
    with the `--unpublished` switch.
  </p>
</div>

## Custom Variables

You can also set your own front matter variables you can access in Liquid. For
instance, if you set a variable called `food`, you can use that in your page:

{% raw %}
```liquid
---
food: Pizza
---

<h1>{{ page.food }}</h1>
```
{% endraw %}

You can also use a page's front matter variables in other places like layouts or includes, and you can even reference those variables in loops through pages or as part of more complex queries (see [Liquid filters](/docs/liquid/filters/) for more information).

## Predefined Variables for Posts

These are available out-of-the-box to be used in the front matter for a post.

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
          A date here overrides the date from the name of the post. This can be
          used to ensure correct sorting of posts. A date is specified in the
          format <code>YYYY-MM-DD HH:MM:SS +/-TTTT</code>; hours, minutes, seconds, and timezone offset
          are optional.
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

          Instead of placing posts inside of folders, you can specify one or
          more categories that the post belongs to. When the site is generated
          the post will act as though it had been set with these categories
          normally. Categories (plural key) can be specified as a <a
          href="https://en.wikipedia.org/wiki/YAML#Basic_components">YAML list</a> or a
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

          Similar to categories, one or multiple tags can be added to a post.
          Also like categories, tags can be specified as a <a
          href="https://en.wikipedia.org/wiki/YAML#Basic_components">YAML list</a> or a
          space-separated string.

        </p>
      </td>
    </tr>
  </tbody>
</table>

<div class="note">
  <h5>Don't repeat yourself</h5>
  <p>
    If you don't want to repeat your frequently used front matter variables
    over and over, define
    <a href="{{ '/docs/configuration/front-matter-defaults/' | relative_url }}" title="Front Matter defaults">defaults</a>
    for them and only override them where necessary (or not at all). This works
    both for predefined and custom variables.
  </p>
</div>

## Advanced Front Matter Data Structures

YAML allows for pretty sophisticated methods of structuring data, for example representing arrays or hashes (key/value). You can also write out longer multi-line strings.

<!-- Add Ruby Front Matter documentation here… -->
