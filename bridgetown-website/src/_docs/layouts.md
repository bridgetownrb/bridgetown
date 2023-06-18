---
title: Layouts
order: 150
top_section: Designing Your Site
category: layouts
---

Layouts are templates that wrap around your [resource's content](/docs/resources). They allow you to have the source code for your template in one place so you don't have to repeat things like your navigation and footer on every page.

Layouts live in the `_layouts` folder. The convention is to have a base template called `default.{erb,liquid,etc.}` and have other layouts [inherit](#inheritance) from this as needed.

{{ toc }}

## Usage

The first step is to put the template source code in `default.html`. `content` is a special variable, the value is the rendered content of the resource being wrapped.

{% raw %}
```liquid
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{{ resource.data.title }}</title>
  </head>
  <body>
    <nav>
      <a href="/">Home</a>
      <a href="/blog/">Blog</a>
    </nav>
    <h1>{{ resource.data.title }}</h1>
    <section>
      {{ content }}
    </section>
    <footer>
      &copy; to me
    </footer>
  </body>
</html>
```
{% endraw %}

You have full access to the front matter of the resource. In the example above, `resource.data.title` comes from the resource's front matter.

Once you've set up one or more layouts, you can specify what layout you'd like to use in your resource's front matter.

```markdown
---
title: My First Page
layout: default
---

This is the content of my page
```

The rendered output of this resource then is:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>My First Page</title>
  </head>
  <body>
    <nav>
      <a href="/">Home</a>
      <a href="/blog/">Blog</a>
    </nav>
    <h1>My First Page</h1>
    <section>
      This is the content of my page
    </section>
    <footer>
      &copy; to me
    </footer>
  </body>
</html>
```

You can also use [front matter defaults](/docs/content/front-matter-defaults/) to to avoid having to set a layout explicitly for every resource. Note that if you have defaults in place and you _don't_ want a certain resource to render in a layout, you can specify `layout: none` in the resource's front matter.

{%@ Note do %}
  If you you're using ERB or another Ruby template language for your layout, try using the more idiomatic `yield` instead of `content`. Refer to the [ERB and Beyond](/docs/template-engines/erb-and-beyond) docs for further details.
{% end %}

## New! Declarative Shadow DOM

An emerging technology which has the potential to change how we approach development of layout and modular composition on the web is called [Declarative Shadow DOM (DSD)](/docs/content/dsd). Starting in Bridgetown 1.3, you can utilize DSD in your layouts and components for increased separation between presentation logic and content, scoped styles which won't inadvertently affect other parts of the page (or other templates), and many other benefits. Check out our [documentation on DSD](/docs/content/dsd) for further details.

## Inheritance

Layout inheritance is useful when you want to add something to an existing layout for a portion of resources on your site. A common example of this is blog posts, you might want a post to display the date and author but otherwise be identical to your base layout.

To achieve this you need to create another layout which specifies your original layout in front matter. For example this layout will live at `_layouts/post.html`:

{% raw %}
```liquid
---
layout: default
---
<p>{{ resource.data.date }} - Written by {{ resource.data.author }}</p>

{{ content }}
```
{% endraw %}

Now posts can use this layout while the rest of the resources use the default.

## Variables

You can set front matter in layouts as well. Just use the `layout` variable instead of `resource`. For example:

{% raw %}
```liquid
---
city: San Francisco
---
<p>{{ layout.data.city }}</p>

{{ content }}
```
{% endraw %}
