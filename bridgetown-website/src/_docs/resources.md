---
title: Resources
order: 10
next_page_order: 10.5
top_section: Content
category: resources
---

<p><ui-label class="tag is-rounded is-warning" style="vertical-align: 2px;"><ui-icon class="icon"><i class="fa fa-exclamation-triangle"></i></ui-icon></ui-label> Marked experimental and currently opt-in, the resource content engine was built with a singular purpose in mind: to replace the myriad of confusing options and edge cases around pages, posts, collection documents, and data files (along with related concepts such as categories, tags, permalinks, etc.) with a single unifying concept: the <strong>resource</strong>.</p>

To switch your Bridgetown site to use resource engine instead of the legacy engine, add the following to your `bridgetown.config.yml` config file:

```yaml
content_engine: resource
```

{% rendercontent "docs/note", type: "warning" %}
The legacy content engine will be deprecated and eventually removed prior to the release of Bridgetown 1.0. Until that time (when our overall documentation will be completely refreshed), consider this doc page to supersede other docs regarding various configurations and behaviors (aka how custom collections are defined, permalinks, taxonomies, template syntax, and more).
{% endrendercontent %}

{% toc %}

## Architecture

The resource is a 1:1 mapping between a unit of content and a URL (remember the acronym Uniform **Resource** Locator?). A "unit of content" is typically a Markdown or HTML file along with [YAML front matter](/docs/front-matter) saved somewhere in the `src` folder.

While certain resources don't actually get written to URLs such as data files (and other resources and/or collections can be marked to avoid output), the concept is sound. Resources encapsulate the logic for how raw data is transformed into final content within the site rendering pipeline.

Resources come with a merry band of objects to help them along the way. These are called Origins, Models, Transformers, and Destinations. Here's a diagram of how it all works.

![The Resource Rendering Pipeline](/images/resource-pipeline.png)
{: .my-8}

Let's say you add a new blog post by saving `src/_posts/2021-05-10-super-cool-blog-post.md`. To make the transition from a Markdown file with Liquid or ERB template syntax to a final URL on your website, Bridgetown takes your data through several steps:

1. It finds the appropriate origin class to load the post. The posts collection file reader uses a special **origin ID** identify the file (in this case: `file://posts.collection/_posts/2021-05-10-super-cool-blog-post.md`). Other origin classes could handle different protocols to download content from third-party APIs or load in content directly from scripts.
2. Once the origin provides the post's data it is used to create a model object. The model will be a `Bridgetown::Model::Base` object by default, but you can create your own subclasses to alter and enhance data, or for use in a Ruby-based CMS environment. For example, `class Post < Bridgetown::Model::Base; end` will get used automatically for the `posts` collection (because Bridgetown will use the Rails inflector to map `posts` to `Post`). You can save subclasses in your `plugins` folder.
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
  Term: {{ term.label }}
{% endfor %}
```

```eruby
<!-- ERB -->

Title: <%= site.taxonomy_types.genres.metadata.title %>

<% page.taxonomies.genres.terms.each do |term| %>
  Term: <%= term.label %>
<% end %>
```

## Resource Relations

You can configure one-to-one, one-to-many, or many-to-many relations between resources in different collections. You can then add the necessary references via front matter or metadata from an API request and access those relations in your templates, plugins, and components.

For example, given a config of:

```yaml
collections:
  actors:
    output: true
    relations:
      has_many: movies
  movies:
    output: true
    relations:
      belongs_to:
        - actors
        - studio
  studios:
    output: true
    relations:
      has_many: movies
```

The following data accessors would be available:

* `actor.relations.movies`
* `movie.relations.actors`
* `movie.relations.studio`
* `studio.relations.movies`

The `belongs_to` type relations are where you add the resource references in front matter—Bridgetown will use a resource's slug to perform the search. `belongs_to` can support solo or multiple relations. For example:

```yaml
# _movies/_1982/blade-runner.md
name: Blade Runner
description: A blade runner must pursue and terminate four replicants who stole a ship in space, and have returned to Earth to find their creator.
year: 1982
actors:
  - harrison-ford # _actors/_h/harrison-ford.md
  - rutger-howard # _actors/_r/rutger-howard.md
  - sean-young # _actors/_s/sean-young.md
studio: warner-brothers # _studios/warner-brothers.md
```

Thus if you were building a layout for the movies collection, it might look something like this:

```erb
<!-- src/_layouts/movies.erb -->

<h1><%= resource.data.name %> (<%= resource.data.year %>)</h1>
<h2><%= resource.data.description %></h2>

<p><strong>Starring:</strong></p>

<ul>
  <% resource.relations.actors.each do |actor| %>
    <li><%= link_to actor.name, actor %></li>
  <% end %>
</ul>

<p>Released by <%= link_to resource.relations.studio.name, resource.relations.studio %></p>
```

The three types of relations you can configure are:

* **belongs_to**: a single string or an array of strings which are the slugs of the resources you want to reference
* **has_one**: a single resource you want to reference will define the slug of the current resource in _its_ front matter
* **has_many**: multiple resources you want to reference will define the slug of the current resource in their front matter

The "inflector" loaded in from Rails' ActiveSupport is used to convert between singular and plural collection names automatically. If you need to customize the inflector with words it doesn't specifically recognize, create a plugin and add your own:

```ruby
ActiveSuport::Inflector.inflections(:en) do |inflect|
  inflect.plural /^(ox)$/i, '\1\2en'
  inflect.singular /^(ox)en/i, '\1'
end
```

## Configuring Permalinks

Bridgetown uses permalink "templates" to determine the default permalink to use for resource destination URLs. You can override a resource permalink on a case-by-case basis by using the `permalink` front matter key. Otherwise, the permalink is determined as follows (unless you change the site config):

* For pages, the permalink matches the path of the file. So `src/_pages/i/am/a/page.md` will output to "/i/am/a/page/".
* For posts, the permalink is derived from the categories, date, and slug (aka filename, but you can change that with a `slug` front matter key).
* For all other collections, the permalink matches the path of the file along with a collection prefix. So `src/_movies/horror/alien.md` will output to `/movies/horror/alien/`

Bridgetown ships a few permalink "styles". The posts permalink style is configured by the `permalink` key in the config file. If the key isn't present, the default is `pretty`. Permalink styles can also be used for your custom collections.

The available styles are:

* `pretty`: `/[collection]/:categories/:year/:month/:day/:slug/`
* `pretty_ext`: `/[collection]/:categories/:year/:month/:day/:slug.*`
* `simple`: `/[collection]/:categories/:slug/`
* `simple_ext`: `collection_prefix}/:categories/:slug.*`

(Including `.*` at the end simply means it will output the resource with its own slug and extension. Alternatively, `/` at the end will put the resource in a folder of that slug with `index.html` inside.)

To set a permalink style or template for a collection, add it to your collection metadata in `bridgetown.config.yml`. For example:

```yaml
collections:
  articles:
    permalink: pretty
```

would make your articles collection behave the same as posts. Or you can create your own template:

```yaml
collections:
  articles:
    permalink: /lots-of/:collection/:year/:title/
```

## Differences Between Resource and Legacy Engines

* The most obvious differences are what you use in templates (Liquid or ERB). For example, instead of `site.posts` in Liquid or `site.posts.docs` in ERB, you'd use `collections.posts.resources` (in both Liquid and ERB). (`site.collection_name_here` syntax is no longer available.) Pages are just another collection now so you can iterate through them as well via `collections.pages.resources`.
* Resources don't have a `url` variable. Your templates/plugins will need to reference either `relative_url` or `absolute_url`. Also, the site's `baseurl` (if configured) is built into both values, so you won't need to prepend it manually.
* Whereas the `id` of a document is the relative destination URL, the `id` of a resource is its origin id. You can define an id in front matter separately however.
* The paginator items are now accessed via `paginator.resources` instead of `paginator.documents`.
* Instead of `pagination:\n  enabled: true` in your front matter for a paginated page, you'll put the collection name instead. Also you can use the term `paginate` instead of `pagination`. So to paginate through posts, just add `paginate:\n  collection: posts` to your front matter.
* Categories and tags are collated from all collections (even pages!), so if you used category/tag front matter manually before outside of posts, you may get a lot more site-wide category/tag data than expected.
* Since user-authored pages are no longer loaded as `Page` objects and everything formerly loaded as `Document` will now be a `Resource::Base`, plugins will need to be adapted accordingly. The `Page` class will eventually be renamed to `GeneratedPage` to indicate it is only used for content generated by plugins.
* With the legacy engine, any folder starting with an underscore within a collection would be skipped. With the resource engine, folders can start with underscores but they aren't included in the final permalink. (Files starting with an underscore are always skipped however.)
* The `YYYY-MM-DD-slug.ext` filename format will now work for any collection, not just posts.
* Structured data files (aka YAML, JSON, CSV, etc.) starting with triple-dashes/front-matter can be placed in collection folders, and they will be read and transformed like any other resource. (CSV/TSV data gets loaded into the `rows` front matter key).
* The [Document Builder API](/docs/plugins/external-apis) no longer works when the resource content engine is configured. We'll be restoring this functionality in a future point release of Bridgetown.
* Automatic excerpts are not included in the current resource featureset. We'll be opening up a brand-new Excerpt/Summary API in the near future.

{% endraw %}