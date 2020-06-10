---
title: Liquid Components
order: 8
top_section: Structure
category: liquid-components
---

Templates in Bridgetown websites are powered by the [Liquid template engine](/docs/liquid). You can use Liquid in layouts and HTML pages as well as inside of content such as Markdown text.

A key aspect of Bridgetown's configuration of Liquid is the ability to render Liquid Components. A component is a reusable piece of template logic (sometimes referred to as a "partial") that can be included in any part of the site, and a full suite of components can comprise what's often called a "design system".

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

{% rendercontent "sections/aside", heading: "Some Additional Context", type: "important", authors: page.additional_authors %}
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

You can use components [provided by others via plugins](/docs/plugins/source-manifests), or you can write your own components. You can also nest components within components. Here's an example layout from this website used for our component previewing tool (more on that later):

{% raw %}
```liquid
{% rendercontent "shared/page_layout" %}
  {% rendercontent "shared/box" %}
    {% render "shared/back_to_button", label: "Components List", url: "/components/" %}
    {% render "shared/header_subpage", title: page.title %}

    <div class="content">
      {% render "component_preview/metadata", component: page.component %}
      {% render "component_preview/variables", component: page.component %}
    </div>
  {% endrendercontent %}
  {% render "component_preview/preview_area", page: page %}
{% endrendercontent %}
```
{% endraw %}

### Component Front Matter

A fully-fledged Liquid Component includes [front matter](/docs/front-matter) which describes the component and the variables it accepts. This can be used as part of a tool which provides "component previews", and in the future, it would allow for on-the-fly validation of incoming variable data.

Here's an example of a component with front matter:

{% raw %}
```liquid
---
name: Widget Card
description: Displays a card about a widget that you can open.
variables:
  title:
    - string
    - The title of the card displayed in a header along the top.
  show_footer: [boolean, Display bottom footer.]
  theme?: object # optional variable
  content: markdown
---

<div class="widget card {{ theme | default: "default" }}">
  <div class="card-title">{{ title }}</div>
  <div class="card-body">{{ content }}</div>
  {% if show_footer %}
    <div class="card-footer"><button>Open the Widget</button></div>
  {% endif %}
</div>
```
{% endraw %}

## Sidecar Frontend Assets

As part of a component-based design system, you might want to include CSS and/or Javascript files alongside your components, so that the styles for your components are defined in the same folder structure as the component templates themselves, and any client-side interactivity related to the component is also defined in-place. Here's an example file structure:

```shell
.
├── src
│   ├── _components
│   │   ├── navbar.scss
│   │   ├── navbar.js
│   │   ├── navbar.liquid
│   │   └── card.scss
│   │   └── card.liquid
```

_(Documentation on how to configure Webpack to use those sidecar assets forthcoming…)_

_(Describe how to set up hybrid Liquid + Web Components easily with LitElement…)_

## Component Previews

Using the reflection provided by the Liquid Component spec, we've built a preview tool to show off some of the components used on this site. [Take a peek here.](/components)

Our goal is to eventually release this as a standalone plugin, but in the meantime feel free to [grab the code out of our repository](https://github.com/bridgetownrb/bridgetown/tree/master/bridgetown-website).

## The Include Tag (Deprecated)

As part of Bridgetown's past Jekyll heritage, you may be familiar with the `include` tag as a means of loading partials into templates and passing variables/parameters. This tag is now deprecated and will be removed once Bridgetown 1.0 is released in late 2020. The `render` tag offers greater room for performance optimizations and requires explicit declaration of available variables rather than relying on global variables—in other words, within a component file, you can't access `page` or `site`, etc., unless you specifically pass `page` or `site` in as a variable. Example:

{% raw %}
```liquid
{% render "navbar", site: site %}
```
{% endraw %}

In many cases, you may not need to pass such large objects and can be more choosy in how you use variables. For example, maybe you can use `site.metadata` or `page.url`:

{% raw %}
```liquid
{% render "navbar", metadata: site.metadata, current_url: page.url %}
```
{% endraw %}

This will make testing and previewing this component easier in the future, because you'll be able to define "mock" data for these variables.

**Tips for migrating to `render`:**

* Files must not contain hyphens (`-`). Use underscores instead (`_`). So `my_widget`, not `my-widget`.
* You don't include extensions in the path. It automatically defaults to either `.html` or `.liquid` (preferred). So `my_widget`, not `my_widget.html`
* As mentioned, any variables you use will have to be passed in explictly. No variables in the scope of a page or layout are available by default in a component.
* The `rendercontent` block tag automatically converts anything you put inside of it from Markdown to HTML. So even in an HTML layout/page, if you have Markdown text inside the block, it will be converted.

**Looking for [previous documentation regarding the include tag](/docs/structure/includes)?**