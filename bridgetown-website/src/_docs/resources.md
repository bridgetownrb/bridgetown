---
title: Resources
order: 10
next_page_order: 10.5
top_section: Content
category: resources
---

Marked experimental and currently opt-in, the resource content engine was built with a singular purpose in mind: to replace the myriad of confusing options and edge cases around pages, posts, collection documents, and data files (along with related concepts such as categories, tags, permalinks, etc.) with a single unifying concept: the **resource**.

To switch your Bridgetown site to use resource engine instead of the legacy engine, add the following to your `bridgetown.config.yml` config file:

```yaml
content_engine: resource
```

{% rendercontent "docs/note", type: "warning" %}
The legacy content engine will be deprecated and eventually removed prior to the release of Bridgetown 1.0. Until that time (when our overall documentation will be completely refreshed), consider this doc page to supersede other docs regarding various configurations and behaviors (aka how custom collections are defined, permalinks, taxonomies, template syntax, and more).
{% endrendercontent %}

{% toc %}

## Architecture

The resource is a 1:1 mapping between a unit of content and a URL (remember the acronym Uniform **Resource** Locator?). While certain resources don't actually get written to URLs such as data files, (and other resources and/or collections can be marked to avoid output), the concept is sound. Resources encapsulate the logic for how raw data is transformed into final content within the site rendering pipeline.

Resources come with a merry band of objects to help them along the way. These are called Origins, Models, Transformers, and Destinations. Here's a diagram of how it all works.

![The Resource Rendering Pipeline](/images/resource-pipeline.png)
{: .my-8}

Let's say you add a new blog post by saving `src/_posts/2021-05-10-super-cool-blog-post.md`. To make the transition from a Markdown file with Liquid or ERB template syntax to a final URL on your website, Bridgetown takes your data through several steps:

1. It finds the appropriate origin class to load the post. The posts collection file reader uses a special **origin ID** identify the file (in this case: `file://posts.collection/_posts/2021-05-10-super-cool-blog-post.md`). Other origin classes could handle different protocols to download content from third-party APIs or load in content directly from scripts.
2. Once the origin provides the post's data it is used to create a model object. The model will be a `Bridgetown::Model::Base` object by default, but you can create your own subclasses to alter and enhance data, or for use in a Ruby-based CMS environment. For example, `class Post < Bridgetown::Model::Base; end` will get used automatically for the `posts` collection (because Bridgetown will use the Rails inflector to map `posts` to `Post`). Subclasses can be saved in the `plugins` folder.
3. The model then "emits" a resource object. The resource is provided a clone of the model data which it can then process for use within template like Liquid, ERB, and so forth. Resources may also point to other resources within their collection, and templates can access resources through various means (looping through collections, referencing resources by source paths, etc.)
4. The resource is transformed by a transformer object which runs a pipeline to convert Markdown to HTML, render Liquid or ERB templates, and any other conversions specified—as well as optionally place the resource output within a converted layout.
5. Finally, a destination object is responsible for determining the resource's "permalink" based on configured criteria or the presence of `permalink` front matter. It will then write out to the output folder using a static file name matching the destination permalink.

## Builtin Collections

With the resource content engine, Bridgetown comes with three collections configured out of the box. These are

* `data`, located in the `src/_data` folder
* `pages`, located in either the `src` top-level folder or the `src/_pages` folder
* `posts`, located in the `src/_posts` folder

The data collection doesn't output to any URL and is used strictly to provide a complete merged dataset via the `site.data` variable.

Pages are for generic, standalone (aka not dated) pages which will output at a URL similar to their file path. So `src/i/am/a-page.html` will end up with the URL `/i/am/a-page/`.

Posts are for dated articles which will output at a URL based on the configured permalink style which might include category and date information. Posts are typically saved in a `YYYY-MM-DD-slug-goes-here.EXT` format which will cause the date to be extracted from the filename prefix.

## Custom Collections

You're by no means limited to the builtin collections. You can create custom collections with any name you choose. By default they will behave similar to standalone pages, but you can configure them to behave in other ways (maybe like posts). For example, you could create an events collection which would function similar to posts, and you could even allow future-dated content to publish (unlike what's typical for posts).

```yaml
# bridgetown.config.yml

collections:
  events:
    output: true
    permalink: pretty
    future: true
```

Thus an event saved at `src/_events/2021-12-15-merry-christmas.md` would output to the URL `/events/2021/12/15/merry-christmas/`.

You can control way a collection is sorted by specifying the front matter key (default is either filename or date if present) as well as the direction as either ascending (default) or descending.

```yaml
collections:
  reverse_ordered:
    output: true
    sort_by: order
    sort_direction: descending
```

## Taxonomies

Bridgetown comes with two builtin taxonomies: **category** and **tag**.

Categories are usually used to structure resources in a way that affects their output URLs and easily match up with specialized archive pages. It's a good way to "group" like-minded resources together.

Tags are considered more of a flat "folksonomy" that you can apply to resources which are purely useful for display, searching, or viewing related items.

You can use a singular front matter key "category / tag" or a plural "categories / tags". If using the plural form but only providing a string, the categories/tags will be split via a space delimiter. Otherwise provide an array of values, like so:

```yaml
categories:
  - category 1
  - another category 2
tags:
  - blessed
  - super awesome
```

In addition to the builtin taxonomies, you can define your own taxonomies. For example, if you were setting up a website all about music, you could create a "genre" taxonomy. Just set it up in the config:

```yaml
# bridgetown.config.yml

taxonomies:
  genre:
    key: genres
    title: "Musical Genre"
    other_metadata: "can go here!"
```

Then use that front matter key in your resources:

```yaml
genres:
  - Jazz
  - Big Band
```

## Accessing Resources in Templates

{% raw %}
The simplest way to access resources in your templates is to use the `collections` variable, available now in both Liquid and Ruby-based templates.

```liquid
<!-- Liquid -->

Title: {{ collections.genre.title }}

First URL: {{ collections.genre.resources[0].relative_url }}
```

```eruby
<!-- ERB -->

Title: <%= collections.genre.metadata.title %>

First URL: <%= collections.genre.resources[0].relative_url %>
```

### Loops and Pagination

You can easily loop through collection resources by name, e.g., `collections.posts.resources`, but much of the time you'll probably want to use a paginator:

```liquid
<!-- Liquid -->

{% for post in paginator.resources %}
  <article>
    <a href="{{ post.relative_url }}"><h2>{{ post.title }}</h2></a>

    <p>{{ post.description }}</p>
  </article>
{% endfor %}
```

```eruby
<!-- ERB -->

<% paginator.resources.each do |post| %>
  <article>
    <a href="<%= post.relative_url %>"><h2><%= post.data.title %></h2></a>

    <p><%= post.data.description %></p>
  </article>
<% end %>
```

Read more about [how the paginator works here](/docs/content/pagination).

### Taxonomies

Accessing taxonomies for resources is simple as well:

```liquid
<!-- Liquid -->

Title: {{ site.taxonomy_types.genres.metadata.title }}

{% for term in page.taxonomies.genres.terms %}
  Term: {{ term }}
{% endfor %}
```

```eruby
<!-- ERB -->

Title: <%= site.taxonomy_types.genres.metadata.title %>

<% page.taxonomies.genres.terms.each do |term| %>
  Term: <%= term.label %>
<% end %>
```

## Configuring Permalinks

TBC

## Differences Between Resource and Legacy Engines

So many!

{% endraw %}