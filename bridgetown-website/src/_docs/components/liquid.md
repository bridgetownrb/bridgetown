---
title: Liquid Components
category: components
top_section: Designing Your Site
order: 0
---

By default, templates in Bridgetown websites are powered by the [Liquid template engine](/docs/templates/liquid). You can use Liquid in layouts and HTML pages as well as inside of content such as Markdown text.

A component is a reusable piece of template logic (sometimes referred to as a "partial") that can be included in any part of the site, and a full suite of components can comprise what is often called a "design system".

Liquid components can be combined with front-end component strategies using **web components** or other JavaScript libraries/frameworks for a [hybrid static/dynamic approach](/docs/components#hybrid-components).

{%= toc %}

## Usage

Including a component within a content document or design template is done via a `render` tag or `rendercontent` tag. Here is a simple example:

{% raw %}
```liquid
Here is some **Markdown** text. Sign up for my newsletter!

{% render "forms/newsletter" %}

_Thank you!_
```
{% endraw %}

This would attempt to load the component defined in `src/_components/forms/newsletter.liquid` and render that into the document.

Here is a more complex example using a block and variables:

{% raw %}
```liquid
Really interesting content…

{% rendercontent "sections/aside", heading: "Some Additional Context", type: "important", authors: resource.data.additional_authors %}
  Read what some of our panelists have to say about the matter.

  And **that's all folks**.
{% endrendercontent %}

### Wrapping Up

And in summary…
```
{% endraw %}

This would load the component in `src/_components/sections/aside.liquid`, which might look something like this:

{% raw %}
```liquid
{%- assign typeclass = "sidebar-default" %}
{%- if type == "important" %}
{%- assign typeclass = "sidebar-important" %}
{%- endif %}
<aside class="sidebar {{ typeclass }}">
  <h3>{{ heading }}</h3>
  {{ content }}
  <p class="authors">{{ authors | array_to_sentence_string }}</p>
</aside>
```
{% endraw %}

You can use components [provided by others via plugins](/docs/plugins/source-manifests), or you can write your own components. You can also nest components within components. Here's an example layout:

{% raw %}
```liquid
{% rendercontent "shared/page_layout" %}
  {% rendercontent "shared/box" %}
    {% render "shared/back_to_button", label: "Components List", url: "/components/" %}
    {% render "shared/header_subpage", title: resource.data.title %}

    <div class="content">
      {% render "component_preview/metadata", component: resource.data.component %}
      {% render "component_preview/variables", component: resource.data.component %}
    </div>
  {% endrendercontent %}
  {% render "component_preview/preview_area", resource: resource.data %}
{% endrendercontent %}
```
{% endraw %}

## The "with" Tag

Instead of passing variable data to a block-style component inline with the `rendercomponent` definition, you can also use the `with` tag. This is great for components which combine a bunch of content regions into a single markup composition.

Here's an example of how you might author a navbar component using `with`. First we'll define the component itself:

{% raw %}
```liquid
<nav class="navbar">
  <div class="navbar-logo">
    {{ logo }}
  </div>

  <div class="navbar-start">
    {{ items_start }}
  </div>

  <div class="navbar-end">
    {{ items_end }}      
  </div>
</nav>
```
{% endraw %}

Now we can render that component and fill in the `logo`, `items_start`, and `items_end` regions:

{% raw %}
```html
{% rendercontent "navbar" %}
  {% with logo %}
    <a class="navbar-item" href="/">
      Awesome Site
    </a>
  {% endwith %}

  {% with items_start %}
    <a class="navbar-item" href="/">Home</a>
    <a class="navbar-item" href="/about">About</a>
    <a class="navbar-item" href="/posts">Posts</a>
  {% endwith %}

  {% with items_end %}
    <div class="navbar-item search-item">
      {% render "bridgetown_quick_search/search", placeholder: "Search", input_class: "input" %}
    </div>
    <a class="navbar-item is-hidden-desktop-only" href="https://twitter.com/{{ metadata.twitter }}" target="_blank" rel="noopener">
      <span class="icon"><i class="fa fa-twitter is-size-6"></i></span>
      <span class="is-hidden-tablet">Twitter</span>
    </a>
  {% endwith %}
{% endrendercontent %}
```
{% endraw %}

Normally content inside of `with` tags is not processed as Markdown (unlike the default behavior of `rendercontent`). However, you can add a `:markdown` suffix to tell `with` to treat it as Markdown. Example:

{% raw %}
```liquid
{% rendercontent "article" %}
  {% with title:markdown %}
    ## Article Title
  {% endwith %}

  Some _nifty_ content here.
{% endrendercontent %}
```
{% endraw %}

## Rendering Liquid Components from Ruby-based Templates

You can use the `liquid_render` helper from Ruby-based templates to render Liquid components.

```erb
<%%= liquid_render "test_component", param: "Liquid FTW!" %>
```

If you pass a block to `liquid_render`, it will utilize the `rendercontent` Liquid tag and the block contents will be captured and made available via the `content` variable.

## History of the Include Tag

As part of Bridgetown's past Jekyll heritage, you may be familiar with the `include` tag as a means of loading partials into templates and passing variables/parameters. This tag was removed in Bridgetown 1.0. The `render` tag offers greater room for performance optimizations and requires explicit declaration of available variables rather than relying on global variables—in other words, within a component file, you can't access `page` or `site`, etc., unless you specifically pass `page` or `site` in as a variable. Example:

{% raw %}
```liquid
{% render "navbar", site: site %}
```
{% endraw %}

In many cases, you may not need to pass such large objects and can be more choosy in how you use variables. For example, maybe you can use `site.metadata` or `resource.relative_url`:

{% raw %}
```liquid
{% render "navbar", metadata: site.metadata, current_url: resource.relative_url %}
```
{% endraw %}

**Tips for migrating to `render`:**

* Files must not contain hyphens (`-`). Use underscores instead (`_`). So `my_widget`, not `my-widget`.
* You don't include extensions in the path. It automatically defaults to either `.html` or `.liquid` (preferred). So `my_widget`, not `my_widget.html`
* As mentioned, any variables you use will have to be passed in explictly. No variables in the scope of a page or layout are available by default in a component.
* The `rendercontent` block tag automatically converts anything you put inside of it from Markdown to HTML. So even in an HTML layout/page, if you have Markdown text inside the block, it will be converted.
