---
title: Front Matter Defaults
hide_in_toc: true
order: 0
category: configuration
---

Using [front matter](/docs/front-matter/) is one way that you can specify configuration in the pages and posts for your site. Setting things like a default layout, or customizing the title, or specifying a more precise date/time for the post can all be added to your page or post front matter.

Often times, you will find that you are repeating a lot of configuration options. Setting the same layout in each file, adding the same category to a post, etc. You can even add custom variables like author names, which might be the same for the majority of posts on your blog.

There are two ways to accomplish this: the data cascade, and via your site's configuration file.

# The Data Cascade

New in Bridgetown 0.17, you can add `_defaults.yml` (also `.yaml` or `.json`) files anywhere in your source tree, which will then cause a "data cascade". In other words, any pages/documents in that folder or in a subfolder will use the front matter data contained in the defaults file. Defaults files in subfolders can also potentially overwrite values contained in parent folders (hence the term "cascade").

For example, if you want all posts to have the layout "post" without having to write `layout: post` in each post's front matter, simply add `_defaults.yml` to the `src/_posts` folder:

```yaml
layout: post
```

Now, if you have some posts in a subfolder (let's say `fancy_posts`) and you want those posts to use the "fancy\_post" layout, you could add a second `_defaults.yml` file in that subfolder like so:

```yaml
layout: fancy_post
```

Now all the `fancy_posts` posts will use the `fancy_post` layout. If you had other front matter variables in the parent `_defaults.yml` in `src/_posts`, those would carry over to the `fancy_posts` defaults unless you decide to override them explicitly.

Also, keep in mind these are "default" values, so if you were to add `layout: some_other_layout` to a post, it would overwrite either `layout: post` or `layout: fancy_post`. This is what makes front matter defaults so powerful!

{% rendercontent "docs/note" %}
Defaults files work well for custom collections! Just add a `_defaults.yml` to the collection root folder to set layouts and other variables for your entire collection.
{% endrendercontent %}

{% rendercontent "docs/note" %}
You can also add a defaults file to `src` itself! For example, if you wanted every document on your site (posts, pages, custom collections) to start off with a default thumbnail image, you could simply add `image: /images/thumbnail_image.jpg` to a defaults file in `src` and it would apply globally.
{% endrendercontent %}

## Configuration-based Front Matter Defaults

Instead of (or in addition to) the data cascade, you can set front matter defaults in your configuration file using a special rules-based syntax.

To do this, add a `defaults` key to the `bridgetown.config.yml` file in your project's root folder. The `defaults` key holds an array of scope/values pairs that define what defaults should be set for a particular file path, and optionally, a file type in that path.

Let's say that you want to add a default layout to all pages and posts in your site. You would add this to your `bridgetown.config.yml` file:

```yaml
defaults:
  -
    scope:
      path: "" # an empty string here means all files in the project
    values:
      layout: "default"
```

{% rendercontent "docs/note", title: "Stop and rerun <code>bridgetown serve</code> command." %}
The <code>bridgetown.config.yml</code> master configuration file contains global configurations
    and variable definitions that are read once at execution time. Changes made to <code>bridgetown.config.yml</code> will not trigger an automatic regeneration.
 
Use [Data Files](/docs/datafiles/) to set up metadata variables and other structured content you can be sure will get reloaded during automatic regeneration.
{% endrendercontent %}

Here, we are scoping the `values` to any file that exists in the path `scope`. Since the path is set as an empty string, it will apply to **all files** in your project. You probably don't want to set a layout on every file in your project - like css files, for example - so you can also specify a `type` value under the `scope` key.

```yaml
defaults:
  -
    scope:
      path: "" # an empty string here means all files in the project
      type: "posts"
    values:
      layout: "default"
```

Now, this will only set the layout for files where the type is `posts`.
The different types that are available to you are `pages`, `posts`, `drafts` or any collection in your site. While `type` is optional, you must specify a value for `path` when creating a `scope/values` pair.

As mentioned earlier, you can set multiple scope/values pairs for `defaults`.

```yaml
defaults:
  -
    scope:
      path: ""
      type: "pages"
    values:
      layout: "my-site"
  -
    scope:
      path: "projects"
      type: "pages"
    values:
      layout: "project" # overrides previous default layout
      author: "Ursula K. Le Guin"
```

With these defaults, all pages would use the `my-site` layout. Any html files that exist in the `projects/`
folder will use the `project` layout, if it exists. Those files will also have the `page.author`
[liquid variable]({{ '/docs/variables/' | relative_url }}) set to `Ursula K. Le Guin`.

```yaml
collections:
  my_collection:
    output: true

defaults:
  -
    scope:
      path: ""
      type: "my_collection" # a collection in your site, in plural form
    values:
      layout: "default"
```

In this example, the `layout` is set to `default` inside the
[collection]({{ '/docs/collections/' | relative_url }}) with the name `my_collection`.

### Glob patterns in Front Matter defaults

It is also possible to use glob patterns (currently limited to patterns that contain `*`) when matching defaults. For example, it is possible to set specific layout for each `special-page.html` in any subfolder of `section` folder.

```yaml
collections:
  my_collection:
    output: true

defaults:
  -
    scope:
      path: "section/*/special-page.html"
    values:
      layout: "specific-layout"
```

<div class="note warning">
  <h5>Globbing and Performance</h5>
  <p>
    Please note that globbing a path is known to have a negative effect on
    performance and is currently not optimized, especially on Windows.
    Globbing a path will increase your build times in proportion to the size
    of the associated collection directory.
  </p>
</div>

### Precedence

Bridgetown will apply all of the configuration settings you specify in the `defaults` section of your `bridgetown.config.yml` file. You can choose to override settings from other scope/values pair by specifying a more specific path for the scope.

You can see that in the second to last example above. First, we set the default page layout to `my-site`. Then, using a more specific path, we set the default layout for pages in the `projects/` path to `project`. This can be done with any value that you would set in the page or post front matter.

Finally, if you set defaults in the site configuration by adding a `defaults` section to your `bridgetown.config.yml` file, you can override those settings in a post or page file. All you need to do is specify the settings in the post or page front matter. For example:

```yaml
# In bridgetown.config.yml
...
defaults:
  -
    scope:
      path: "projects"
      type: "pages"
    values:
      layout: "project"
      author: "Ursula K. Le Guin"
      category: "project"
...
```

```yaml
# In projects/foo_project.md
---
author: "John Smith"
layout: "foobar"
---
The post text goes here...
```

The `projects/foo_project.md` would have the `layout` set to `foobar` instead
of `project` and the `author` set to `John Smith` instead of `Ursula K. Le Guin` when
the site is built.
