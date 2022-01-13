---
title: Front Matter Defaults
order: 0
top_section: Writing Content
category: resources
---

Using [front matter](/docs/front-matter) is the way you specify metadata for the file-based resources for your site, setting things like a default layout, or customizing the title, or providing taxonomy terms.

Sometimes you will find you're repeating a few configuration options over and over. For example, setting the same layout in each file, adding the same category, etc. You might even want to add author names which are the same for the majority of posts.

There are two ways to accomplish this: the data cascade, and via your site's configuration file.

## The Data Cascade

You can add `_defaults.yml` (also `.yaml` or `.json`) files anywhere in your source tree, which will then cause a "data cascade". In other words, any resources in that folder or in a subfolder will use the front matter data contained in the defaults file. Defaults files in subfolders can also potentially overwrite values contained in parent folders (hence the term "cascade").

For example, if you want all "posts" collection resources to have the layout "post" without having to repeatedly write `layout: post` front matter, simply add `_defaults.yml` to the `src/_posts` folder:

```yaml
layout: post
```

Now, if you have some posts in a subfolder (let's say `fancy_posts`) and you want those posts to use the "fancy\_post" layout, you could add a second `_defaults.yml` file in that subfolder like so:

```yaml
layout: fancy_post
```

Now all the `fancy_posts` posts will use the `fancy_post` layout. If you had other front matter variables in the parent `_defaults.yml` in `src/_posts`, those would carry over to the `fancy_posts` defaults unless you decide to override them explicitly.

Also, keep in mind these are "default" values, so if you were to add `layout: some_other_layout` to a post, it would overwrite either `layout: post` or `layout: fancy_post`. This is what makes front matter defaults so powerful!

{%@ Note do %}
  #### Trick out your collections

  Defaults files work well for custom collections! Just add a `_defaults.yml` to the collection root folder to set layouts and other variables for your entire collection.
{% end %}

{%@ Note do %}
  #### Think globally

  You can also add a defaults file to `src` itself! For example, if you wanted every resource on your site to start off with a default thumbnail image, you could simply add `image: /images/thumbnail_image.jpg` to a defaults file in `src` and it would apply globally.
{% end %}

## Configuration-based Front Matter Defaults

Instead of (or in addition to) the data cascade, you can set front matter defaults in your configuration file using a special rules-based syntax. To do this, add a `defaults` key to the `bridgetown.config.yml` file in your project's root folder.

Let's say that you want to add a default layout to all pages and posts in your site. You would add this to your `bridgetown.config.yml` file:

```yaml
defaults:
  - values:
      layout: "default"
```

{%@ Note type: :warning do %}
  #### Stop and rerun <code>bridgetown start</code>

  The <code>bridgetown.config.yml</code> master configuration file contains global configurations and variable definitions that are read once at execution time. Changes made to <code>bridgetown.config.yml</code> will not trigger an automatic regeneration.

  Use [Data Files](/docs/datafiles) to set up metadata variables and other structured content you can be sure will get reloaded during automatic regeneration.
{% end %}

You probably don't want to set a layout on every file in your project, so you can also specify a `collection` value under the `scope` key.

```yaml
defaults:
  - scope:
      collection: "posts"
    values:
      layout: "default"
```

This will only set the layout for resources in the `posts` collection.

You can set multiple scope/values pairs for `defaults`.

```yaml
defaults:
  - scope:
      collection: "pages"
    values:
      layout: "my-site"
  - scope:
      path: "projects" # scopes to a particular path within your source folder
      collection: "pages"
    values:
      layout: "project" # overrides previous default layout
      author: "Ursula K. Le Guin"
```

With these defaults, all pages would use the `my-site` layout. Any html files that exist in the `projects/` folder will use the `project` layout, if it exists. Those files will also have the `resource.data.author` variable set to `Ursula K. Le Guin`.

```yaml
collections:
  my_collection:
    output: true

defaults:
  - scope:
      collection: "my_collection"
    values:
      layout: "default"
```

In this example, the `layout` is set to `default` inside the [collection](/docs/collections/) with the name `my_collection`.

### Glob patterns in Front Matter defaults

It is also possible to use glob patterns (currently limited to patterns that contain `*`) when matching defaults. For example, it is possible to set specific layout for each `special-page.html` in any subfolder of `section` folder.

```yaml
collections:
  my_collection:
    output: true

defaults:
  - scope:
      path: "section/*/special-page.html"
    values:
      layout: "specific-layout"
```

{%@ Note type: "warning" do %}
  #### Globbing and Performance

  Please note that globbing a path is known to have a negative effect on performance. Globbing a path will increase your build times in proportion to the size of the associated collection directory.
{% end %}

### Precedence

Bridgetown will apply all of the configuration settings you specify in the `defaults` section of your `bridgetown.config.yml` file. You can choose to override settings from other scope/values pair by specifying a more specific path for the scope.

If you set defaults in the site configuration by adding a `defaults` section to your `bridgetown.config.yml` file, you can override those settings in an individual resource's front matter. For example:

```yaml
# In bridgetown.config.yml
...
defaults:
  - scope:
      path: "projects"
      collection: "pages"
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

The `projects/foo_project.md` resource would have the `layout` set to `foobar` instead of `project` and the `author` set to `John Smith` instead of `Ursula K. Le Guin` when the site is built.
