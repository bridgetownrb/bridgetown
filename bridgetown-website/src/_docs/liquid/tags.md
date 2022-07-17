---
title: Liquid Tags
top_section: Designing Your Site
order: 0
category: template-engines
---

All of the standard Liquid
[tags](https://shopify.github.io/liquid/tags/control-flow/) are supported.
Bridgetown has a few built in tags to help you build your site. You can also create
your own tags using [plugins](/docs/plugins/tags).

## Component rendering

You can use the `render` and `rendercontent` tags to embed content and template partials into your main templates. [Read the documentation here](/docs/components/liquid).

## Find tag

You can use the `find` tag to loop through a data object or collection and pull out one or more items to use in your Liquid template. Whereas before you could use the [`where_exp` filter](/docs/liquid/filters/#binary-operators-in-where_exp-filter) to accomplish a similar purpose, this tag is more succinct and has support for single item variables.

The syntax of the tag is as follows:

{% raw %}
```liquid
# Single item:

{% find [item] in [array/collection], [expressions] %}

# Multiple items:

{% find [items] where [array/collection], [expressions] %}
```
{% endraw %}

For example, to find a single entry in the `albums` collection and assign it to the variable `album`:

{% raw %}
```liquid
{% find album in collections.albums.resources, band == resource.data.band, year >= 1980, categories contains "Rock" %}
```
{% endraw %}

Or to find multiple items and assign that array to the variable `albums`:

{% raw %}
```liquid
{% find albums where collections.albums.resources, band == resource.data.band, year >= 1980, categories contains "Rock" %}
```
{% endraw %}

Each expression (separated by a comma) adds an "AND" clause to the conditional logic. If you need OR logic instead, you can still use the `where_exp` filter, or you can write additional `find` tags and [concat](https://shopify.github.io/liquid/filters/concat/) the arrays together (you'll probably also want to use the `uniq` filter to ensure you don't end up with duplicates).

{% raw %}
```liquid
{% find rock_albums where collections.albums.resources, band == resource.data.band, year >= 1980, categories contains "Rock" %}
{% find folk_albums where collections.albums.resources, band == resource.data.band, year >= 1980, categories contains "Folk" %}

{% assign albums = rock_albums | concat: folk_albums | uniq %}
```
{% endraw %}

## Class Map tag

If you've ever had to write a bunch of conditional code and variable assigns to toggle on/off CSS classes based on input variables, you know it can get pretty messy.

But not anymore! Introducing `class_map`:

{% raw %}
```liquid
<div class="{% class_map has-centered-text: resource.data.centered, is-small: small-var %}">
  …
</div>
```
{% endraw %}

In this example, the `class_map` tag will include `has-text-centered` only if `resource.data.centered` is truthy, and likewise `is-small` only if `small-var` is truthy. If you need to run a comparison with a specific value, you'll still need to use `assign` but it'll still be simpler than in the past:

{% raw %}
```liquid
{% if product.data.feature_in == "socks" %}{% assign should_bold = true %}{% endif %}
<div class="{% class_map product: true, bold-text: should_bold, float-right: true %}">
  …
</div>
```
{% endraw %}

## Code snippet highlighting

Bridgetown has built in support for syntax highlighting of over 100 languages
thanks to [Rouge](http://rouge.jneen.net). To render a code block with syntax highlighting, surround your code as follows:

{% raw %}
```liquid
{% highlight ruby %}
def foo
  puts 'foo'
end
{% endhighlight %}
```
{% endraw %}

The argument to the `highlight` tag (`ruby` in the example above) is the
language identifier. To find the appropriate identifier to use for the language
you want to highlight, look for the “short name” on the [Rouge
wiki](https://github.com/jayferd/rouge/wiki/List-of-supported-languages-and-lexers).

{%@ Note type: :warning do %}
  #### Bridgetown processes all Liquid filters in code blocks

  If you are using a language that contains curly braces, you will likely need to
  place <code>{&#37; raw &#37;}</code> and <code>{&#37; endraw &#37;}</code> tags
  around your code. If needed, you can add `render_with_liquid: false` in your
  front matter to disable Liquid entirely for a particular document.
{% end %}

{%@ Note do %}
  You can also use fenced code blocks in Markdown (starting and ending with three
  backticks <code>```</code>) instead of using the `highlight` tag. However, the
  `highlight` tag includes additional features like line numbers (see below).
{% end %}


### Line numbers

There is a second argument to `highlight` called `linenos` that is optional.
Including the `linenos` argument will force the highlighted code to include line
numbers. For instance, the following code block would include line numbers next
to each line:

{% raw %}
```liquid
{% highlight ruby linenos %}
def foo
  puts 'foo'
end
{% endhighlight %}
```
{% endraw %}

### Stylesheets for syntax highlighting

In order for the highlighting to show up, you’ll need to include a highlighting
stylesheet. You can use CSS that's compatible with Pygments—example gallery
[here](https://jwarby.github.io/jekyll-pygments-themes/languages/ruby.html)
or from [its repository](https://github.com/jwarby/jekyll-pygments-themes).

Copy the CSS file (`native.css` for example) into your `styles` directory and import
the syntax highlighter styles into your `index.scss`:

```css
@import "native.css";
```

## Links

### Linking to pages {#link}

To link to a post, a page, collection item, or file, the `link` tag will generate the correct permalink URL for the path you specify. For example, if you use the `link` tag to link to `mypage.html`, even if you change your permalink style to include the file extension or omit it, the URL formed by the `link` tag will always be valid.

You must include the file's original extension when using the `link` tag. Here are some examples:

{% raw %}
```liquid
{% link _collection/name-of-document.md %}
{% link _posts/2016-07-26-name-of-post.md %}
{% link news/index.html %}
{% link /assets/files/doc.pdf %}
```
{% endraw %}

You can also use the `link` tag to create a link in Markdown as follows:

{% raw %}
```liquid
[Link to a document]({% link _collection/name-of-document.md %})
[Link to a post]({% link _posts/2016-07-26-name-of-post.md %})
[Link to a page]({% link news/index.html %})
[Link to a file]({% link /assets/files/doc.pdf %})
```
{% endraw %}

The path to the post, page, or collection is defined as the path relative to the root directory (where your config file is) to the file, not the path from your existing page to the other page.

For example, suppose you're creating a link in `page_a.md` (stored in `pages/folder1/folder2`) to `page_b.md` (stored in  `pages/folder1`). Your path in the link would not be `../page_b.html`. Instead, it would be `/pages/folder1/page_b.md`.

If you're unsure of the path, add {% raw %}`{{ resource.relative_path }}`{% endraw %} to the page and it will display the path.

One major benefit of using the `link` or `post_url` tag is link validation. If the link doesn't exist, Bridgetown won't build your site. This is a good thing, as it will alert you to a broken link so you can fix it (rather than allowing you to build and deploy a site with broken links).

Note you cannot add filters to `link` tags. For example, you cannot append a string using Liquid filters, such as {% raw %}`{% link mypage.html | append: "#section1" %}`{% endraw %}. To link to sections on a page, you will need to use regular HTML or Markdown linking techniques.

### Linking to posts

If you want to include a link to a post on your site, the `post_url` tag will generate the correct permalink URL for the post you specify.

{% raw %}
```liquid
{% post_url 2010-07-21-name-of-post %}
```
{% endraw %}

If you organize your posts in subdirectories, you need to include subdirectory path to the post:

{% raw %}
```liquid
{% post_url /subdir/2010-07-21-name-of-post %}
```
{% endraw %}

There is no need to include the file extension when using the `post_url` tag.

You can also use this tag to create a link to a post in Markdown as follows:

{% raw %}
```liquid
[Name of Link]({% post_url 2010-07-21-name-of-post %})
```
{% endraw %}
