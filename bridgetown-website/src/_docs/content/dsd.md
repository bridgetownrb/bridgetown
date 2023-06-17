---
title: Declarative Shadow DOM
order: 0
top_section: Writing Content
category: resources
---

Welcome to the future! Declarative Shadow DOM (DSD) represents a huge shift in the way we architect and promote modularity on a web page. It's helpful to describe the power and flexibility of DSD by comparing it to what has come before.

Let's look at a typical web page layout and how we might style it. (We'll only concern ourselves with `<body>` for this example.)

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

Oops, this isn't what we want. By simply styling the `header` tag, we've affected both the main header of the page and the header of an individual article block. Let's adding some scoping to remedy this:

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

```style
body#fancy-layout article > header {
  font-weight: 600;
}

article.boldest > header {
  font-weight: 900;
}
```

Wouldn't it be great if we could separate the internal styling from outward-facing styling of each modular building block of a website? Wouldn't it be great if we could define "styling APIs" for our components? Wouldn't it be great if we could simplify the markup of our actual content by ensuring it's not locked inside of all the presentational/structural minutiae of a layout?

Enter Declarative Shadow DOM.

{% raw %}
Bridgetown lets us use the `{% dsd %}…{% enddsd %}` Liquid tag or `<%= dsd do %>…<% end %>` Ruby helper to define a DSD template within any HTML template.

```html
<body>
  {% dsd %}
    <header><slot name="header"></slot></header>
    <slot></slot>
    
    <style>
      header {
        color: indigo;
      }
    </style>
  {% enddsd %}

  <h1 slot="header">I'm the Page Header</h1>
  
  <p>Page content.</p>
  
  <article>
    {% dsd %}
      <header><slot name="header"></slot></header>
      <slot></slot>
      
      <style>
        header {
          color: darkorchid;
        }
      </style>
    {% enddsd %}

    <h2 slot="header">I'm the Article Header</h2>
    
    <p>Article content.</p>
  </article>
</body>
```

{% endraw %}


What's great about this approach is (a) only this element is affected by your stylesheet and nothing else on your page.

{%@ Note do %}
The `<is-land>` web component automatically polyfills DSD, which is an added benefit of using it. Otherwise, the Turbo bundled configuration also includes a site-wide polyfill for DSD. As of the time of this writing, only Firefox (and some older versions of Safari) do not offer built-in DSD support.
{% end %}

{%@ Note type: :warning do %}
Sidecar CSS files processed through the `dsd_style` helper do not get run through PostCSS—aka they must be 100% "vanilla" CSS. Don't be surprised if you try using a feature that's uniquely enabled by your PostCSS config and it's not available within the DSD template.
{% end %}

