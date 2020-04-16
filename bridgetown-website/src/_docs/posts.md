---
title: Posts
order: 11
top_section: Content
category: posts
---

Blogging is a key part of Bridgetown. You can write blog posts as text files and Bridgetown provides everything you need to turn those into a blog. Under the hood, posts are simply a built-in type of [collection](/docs/collections), so you're not obligated to use them if a custom collection makes more sense.

## The Posts Folder

The `_posts` folder in your source folder (`src`) is where your blog posts live. You typically write posts in [Markdown](https://daringfireball.net/projects/markdown/), but HTML is also supported.

## Creating Posts

To create a post, add a file to your `_posts` directory with the following
format:

```
YEAR-MONTH-DAY-title.EXT
```

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit
numbers, and `EXT` is the file extension representing the markup format used in the
file. For example, the following are examples of valid post filenames:

```
2018-12-31-new-years-eve-is-awesome.md
2019-09-12-how-to-write-a-blog.html
```

All blog post files must begin with [front matter](/docs/front-matter/) which is
typically used to set a title, [layout](/docs/layouts/), or other metadata. Here's an example:

```markdown
---
layout: post
title: "Welcome to Bridgetown!"
---

# Welcome

**Hello world**, this is my first Bridgetown blog post.

I hope you like it!
```

<div class="note">
  <h5>Top Tip: Link to other posts</h5>
  <p markdown="1">
    Use the `post_url` [Liquid tag](/docs/liquid/tags/#linking-to-posts) to link to other posts without having to worry about the URLs breaking when the site permalink style changes.
  </p>
</div>

<div class="note">
  <h5>Top Tip: Set your post layout using front matter defaults</h5>
  <p markdown="1">
    To avoid having to include a `layout` variable for every post, try setting a layout as a [front matter default](/docs/configuration/front-matter-defaults/) in your configuration file.
  </p>
</div>

## Permalinks

You can configure [permalinks](/docs/structure/permalinks) for full control of the output URL of your blog posts, such as `https://mydomain.com/vacation/2019/disney-world`. Read all about it in the [permalinks documentation](/docs/structure/permalinks).

## Including images and resources

At some point, you'll want to include images, downloads, or other
digital assets along with your text content. One common solution is to create
a folder in the root of the source folder called something like `assets`,
into which any images, files or other resources are placed. Then, from within
any post, they can be linked to using the site’s root as the path for the asset
to include. The best way to do this depends on the way your site’s (sub)domain
and path are configured, but here are some simple examples in Markdown:

Including an image asset in a post:

```markdown
... which is shown in the screenshot below:
![My helpful screenshot](/assets/screenshot.jpg)
```

Linking to a PDF for readers to download:

```markdown
... you can [get the PDF](/assets/mydoc.pdf) directly.
```

{:.note}
Another alternative is to store images in an assets management service such as [Cloudinary](https://cloudinary.com) and reference those images in your Markdown. You could even write a Liquid filter which lets you specify the image ID and transformation properties in your content and generate the relevant Cloudinary URL. An exercise left for the reader…

## Displaying an index of posts

Creating an index of posts on a top page is easy thanks to [Liquid](/docs/liquid/) tags. Here’s a simple example of how to create a list of links to your blog posts:

{% raw %}
```liquid
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
```
{% endraw %}

Note that the `post` variable only exists inside the `for` loop above. If
you wish to access the currently-rendering page variables (the
variables of the page that has the `for` loop in it), use the `page`
variable instead.

{:.note}
If you have a large number of posts, it's likely you'll want to use the
[Pagination feature](/docs/content/pagination/) to make it easy to browse through
a limited number of posts per page.

## Categories and Tags

Bridgetown has built-in support for categories and tags in blog posts. The difference
between categories and tags is a category can be part of the URL for a post
whereas a tag cannot.

To use these, first set your categories and tags in front matter:

```yaml
---
layout: post
title: A Trip
categories:
  - blog
  - travel
tags: hot summer
---
```

Bridgetown makes the categories available via `site.categories`. Iterating over
`site.categories` on a page gives you another array with two items, the first
item is the name of the category and the second item is an array of posts in that
category.

{% raw %}
```liquid
{% for category in site.categories %}
  <h3>{{ category[0] }}</h3>
  <ul>
    {% for post in category[1] %}
      <li><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
  </ul>
{% endfor %}
```
{% endraw %}

For tags it's exactly the same except the variable is `site.tags`.

You could also specify a single category per post with the category variable instead:

```yaml
category: dessert
```

## Post excerpts

You can access a snippet of a posts's content by using `excerpt` variable on a
post. By default this is the first paragraph of content in the post, however it
can be customized by setting a `excerpt_separator` variable in front matter or
`bridgetown.config.yml`.

```markdown
---
excerpt_separator: <!--more-->
---

Excerpt with multiple paragraphs

Here's another paragraph in the excerpt.
<!--more-->
Out-of-excerpt
```

Here's an example of outputting a list of blog posts with an excerpt:

{% raw %}
```liquid
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
```
{% endraw %}

## Hiding In-Progress Posts

If you have a posts you're still working on and don't want to publish it yet, you can use the `published` front matter variable. Set it to false and your post won't be published on standard builds:

```yaml
---
title: My draft post
published: false
---
```

To preview your site with unpublished posts or pages, run either `bridgetown serve` or `bridgetown build` with the `--unpublished` switch. This will build and output all content files even if `published` is set to `false` in the front matter.