---
title: Declarative Shadow DOM
order: 0
top_section: Designing Your Site
category: layouts
---

_Welcome to the future!_ Declarative Shadow DOM ([DSD](https://konnorrogers.com/posts/2023/what-is-declarative-shadow-dom/)) represents a huge shift in the way we architect and promote modularity on a web page. You can use DSD in your [layouts](/docs/layouts), [components](/docs/components), and generally anywhere it would be beneficial to increase the separation between presentation logic & content and work with advanced scoped styling APIs.

Heads up: if you're upgrading from Bridgetown 1.2 or previous, you'll need to be using esbuild (not Webpack) and must update your base esbuild configuration. It's a snap! Just run:

```shell
bin/bridgetown esbuild update
```

See the [esbuild setup documentation](/docs/frontend-assets#esbuild-setup) for further upgrade instructions.

{%@ Note type: :warning do %}
  You may also need to update your `esbuild.config.js file` so it includes the following configuration option:

  ```js
    globOptions: {
      excludeFilter: /\.(dsd|lit)\.css$/
    }
  ```
{% end %}

{{ toc }}

## Intro to DSD

It's helpful to describe the power and flexibility of DSD by comparing it to what has come before. Let's look at a typical web page layout and how we might style it. (We'll only concern ourselves with `<body>` for this example.)

```html
<body>
  <header>I'm the Page Header</header>
  
  <article>
    <header>I'm the Article Header</header>
  </article>
  
  <style>
  header {
    color: indigo;  
  }
  </style>
</body>
```

Oops, this isn't what we want. By simply styling the `header` tag, we've affected both the main header of the page and the header of an individual article block. Let's adding some selector-based scoping to remedy this:

```html
<body>
  <header>I'm the Page Header</header>
  
  <article>
    <header>I'm the Article Header</header>
  </article>
  
  <style>
  body > header {
    color: indigo;  
  }
  
  article > header {
    color: darkorchid;
  }
  </style>
</body>
```

This is better, but our page layout styles and our "component" styles are still too intermingled. We could remedy this by creating components for things like the article tag, but in more advanced components keeping styles of a component's "internals" and its public-facing child content from colliding with each other can get tricky. And what if you wanted each layout also to have some unique styles but you don't want to add override `<style>` tags or mess around with scoping to body IDs which can land you in specificity wars. Which of these would win?

```css
body#fancy-layout article > header {
  font-weight: 600;
}

article.boldest > header {
  font-weight: 900;
}
```

Wouldn't it be great if we could separate the internal styling from outward-facing styling of each modular building block of a website? Wouldn't it be great if we could define "styling APIs" for our components? Wouldn't it be great if we could simplify the markup of our actual content by ensuring it's not locked inside of all the presentational/structural minutiae of a layout?

## The `dsd` Helper

Enter **Declarative Shadow DOM**.

{% raw %}
Bridgetown lets us use the `{% dsd %}…{% enddsd %}` Liquid tag or `<%= dsd do %>…<% end %>` Ruby helper to define a DSD template within any HTML template. Here's an example expanding from the one above:
{% endraw %}

```eruby
<body>
  <%= dsd do %>
    <header><slot name="header"></slot></header>
    <slot></slot>
    
    <style>
      header {
        color: indigo;
      }
    </style>
  <% end %>

  <h1 slot="header">I'm the Page Header</h1>
  
  <p>Page content.</p>
  
  <article>
    <%= dsd do %>
      <header><slot name="header"></slot></header>
      <slot></slot>
      
      <style>
        header {
          color: darkorchid;
        }
      </style>
    <% end %>

    <h2 slot="header">I'm the Article Header</h2>
    
    <p>Article content.</p>
  </article>
</body>
```

What's great about this approach is:

1. Only the element with a DSD template is affected by the associated styles. The `header` tag at the `body` level, and the `header` tag at the `article` level are separated from each other behind shadow boundaries. This provides what we like to call _encapsulation_ (borrowing terminology from object-oriented programming). Before all HTML + styles operated in a single global namespace called "the DOM". Now we can actually define encapsulated HTML + style DOM trees!
2. Scoping isn't just about styles…it works in JavaScript too! Consider `document.body.querySelectorAll("header")`. Normally, this would give you a list of all `header` tags across the entire webpage, no matter where they appear. But now, you could call `document.body.shadowRoot.querySelectorAll("header")` and get that single header in your DSD template. _Wut??_ Yep, it totally works.
3. By utilizing the [slots mechanism](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_templates_and_slots#adding_flexibility_with_slots) that's part of the shadow DOM spec, you can build your DSD template around various pieces of presentation logic, styled by the template accordingly, and then in the "light DOM" your content can reference those slots to make it *super obvious* what the content is and how it might get presented. Of course many server-side templating systems, Bridgetown included, can make this somewhat clear from a development standpoint by providing building blocks such as layouts and resources and components, but by the time it gets to the browser, you don't really have any sense how the content and the presentation logic are built out and modularized. **Everything just gets flatted into a tree of DOM nodes.** With shadow DOM, you can actually see at the markup and browser dev tools levels how everything gets composed together across your components and templates, making inspecting and debugging much easier. It's like HTML suddenly got super powers!

In addition to the benefits above, you also have the ability to leverage [CSS Shadow Parts](https://developer.mozilla.org/en-US/docs/Web/CSS/::part) (which only work when you have, er, shadow DOM—hence the name!). What's a shadow part? It's when you use the `part=` attribute on an element inside your DSD template, and by doing so it makes it styleable from the "outside". Defining parts and labeling them appropriately is a fantastic way to build up a true "style API" for each layout or component.

{%@ Note do %}
Declarative Shadow DOM is a fairly new specification. As of the time of this writing, some older versions of Safari and Firefox do not offer built-in DSD support. The `<is-land>` web component automatically polyfills DSD, which is an added benefit of using it. Otherwise, the Turbo bundled configuration also includes a site-wide polyfill for DSD.
{% end %}

## Components with Sidecar CSS

As mentioned already, you can use DSD in your Liquid and Ruby components. In addition, Ruby components allow you to write CSS in dedicated stylesheets (aka `my_component.dsd.css`) and reference them directly from your component's DSD template. Let's take a look:

```eruby
<!-- src/_components/simple_component.erb -->
<simple-component>
  <%= dsd do %>
    <slot name="caption"></slot>
    <div>
      <slot></slot>
    </div>
    <%= dsd_style %>
  <% end %>

  <%= content %>
</simple-component>
```

```css
/* src/_components/simple_component.dsd.css */
:host {
  display: block;
  background: var(--surface-1);
  padding: var(--size-4);
}

slot[name="caption"] {
  display: block;
  font-weight: bold;
}

div {
  margin-block-start: var(--size-4);
}
```

Make sure you use the `.dsd.css` extension so esbuild knows not to attempt bundling the component stylesheet into the global `index.css` stylesheet.

{%@ Note type: :warning do %}
Sidecar CSS files processed through the `dsd_style` helper do not get run through PostCSS—aka they must be 100% "vanilla" CSS. Don't be surprised if you try using a feature that's uniquely enabled by your PostCSS config and it's not available within the DSD template.
{% end %}

{%@ Note type: :warning do %}
There are certain "gotchas" when working with scoped styles inside a shadow root. Only a small number of global styles get inherited within a DSD template. For example, you may be surprised if you add an `<a href>` tag inside your DSD template and it looks like a browser's default link style, not your site's link style! There are all sorts of workarounds for issues that may arise, and we hope to refer to helpful educational resources as time passes and DSD becomes more widespread. In the meantime…[try asking the community](/community) for assistance!
{% end %}

## Working with DSD in JavaScript and Hydrating Islands

_Further documentation coming soon…_

Meanwhile, you may be interested in our [documentation on Islands Architecture](/docs/islands).

