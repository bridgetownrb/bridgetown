---
title: Liquid Components
order: 8
top_section: Structure
category: liquid-components
---

Templates in Bridgetown websites are powered by the [Liquid template engine](/docs/liquid). You can use Liquid in layouts and HTML pages as well as inside of content such as Markdown text.

A key aspect of Bridgetown's configuration of Liquid is the ability to render Liquid Components. A component is a reusable piece of template logic (sometimes referred to as a "partial") that can be included in any part of the site, and a full suite of components can comprise what is often called a "design system".

Liquid Components can be combined with front-end component strategies using Web Components or other Javascript libraries/frameworks for a hybrid static/dynamic approach.

{% toc %}

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

## Component Front Matter

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

## Component Previews

Using the reflection provided by the Liquid Component spec, we've built a preview tool to show off some of the components used on this site. [Take a peek here.](/components)

Our goal is to eventually release this as a standalone plugin, but in the meantime feel free to [grab the code out of our repository](https://github.com/bridgetownrb/bridgetown/tree/main/bridgetown-website).

## Sidecar Frontend Assets

As part of a component-based design system, you might want to include CSS and/or Javascript files alongside your components, so that the styles for your components are defined in the same folder structure as the component templates themselves, and any client-side interactivity related to the component is also defined in-place. Here's an example file structure:

```shell
.
├── src
│   ├── _components
│   │   ├── card.liquid
│   │   ├── card.scss
│   │   ├── shared
│   │   │   ├── navbar.scss
│   │   │   ├── navbar.js
│   │   │   └── navbar.liquid
```

Bridgetown comes with a built-in Sass configuration so you can import `.scss` files from the `src/_components` folder. In the above example, to import `card.scss` and `shared/navbar.scss` into your stylesheet, add the following to `frontend/styles/index.scss`:

```scss
@import "components.scss"; // in src/_components
```

And then add the imports to the `src/_components/components.scss` file:

```scss
@import "card.scss";
@import "shared/navbar.scss";
```

To import Javascript files, you can set up a configuration which will automatically require any matching `.js` files in `src/_components`. Simply update your Webpack config by adding an alias under resolve:

```js
// webpack.config.js

  // ...
  resolve: {
    extensions: [".js", ".jsx"],
    alias: {
      liquidComponents: path.resolve(__dirname, "src/_components")
    }
  },
  // ...
```

Then add a Javascript index file to load the components:

```js
// src/_components/index.js

function importAll(r) {
  r.keys().forEach(r)
}

importAll(require.context(".", true, /.js$/))
```

Finally, import that components index file in your main frontend index file:

```js
// frontend/javascript/index.js

import "liquidComponents"
```

### Hybrid Liquid + Web Components

One of the interesting design patterns that emerges when defining Liquid Components this way is the interplay between statically-rendered markup and Javascript-powered interactivity. Unlike static site generators built around client-side technologies such as React, Bridgetown starts you off with the strategic concept that everything originates with "server-rendered" content. What you choose to do with that built HTML _after_ it's presented in the browser is up to you. However, an approach we've come to deeply appreciate is combining a Liquid Component with a Web Component.

[Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_components) is an open standard, an integral part of the fabric of the web and supported by all modern, evergreen browsers. A web component starts life as a custom element in HTML markup which contains one or more dashes, for example `<my-button>` or `<card-heading-title>`. You then direct the browser to load that custom element as a custom Javascript object through use of the `window.customElements.define` method. A web component also comes with a suite of features such as Shadow DOM, Slots, and CSS Shadow Parts to give the component a degree of autonomy and clean separation from the styling and markup concerns of the parent document.

While you can author a web component without using libraries or frameworks of any kind, we recommend using a small library called [LitElement](https://lit-element.polymer-project.org) (or even its tinier sibling [lit-html](https://lit-html.polymer-project.org)) which makes web component development as conceptually straightforward as legacy component frameworks such as Vue or React.

By building "default" markup into your Liquid component, and then using a "hydration-like" strategy to enhance the component in Javascript, you get lightning-fast static markup which works even without Javascript enabled—while at the same time taking advantage of advanced client-side user interface capabilities. You can also take advantage of APIs to render up-to-date content in real-time in the browser after possibly-stale static content has first loaded.

{% rendercontent "docs/note" %}
You don't _have_ to use web components to take advantage of this pattern. You can use any light-weight "Javascript sprinkles" library such as [Stimulus](https://stimulusjs.org) or [Alpine](https://github.com/alpinejs/alpine/) and the concepts remain relatively the same.
{% endrendercontent %}

Here's an example of a component which shows a product price and an Add to Cart button. We'll first define it as a Liquid component and display the price directly as statically-generated HTML. Then we'll define a LitElement-powered web component which updates the price and checks if the product is in stock before enabling the shopping cart interactivity of the button.

`src/_components/product.liquid`:

{% raw %}
```html
---
name: Product Price
description: Displays the price of a product along with an Add to Cart button.
variables:
  sku: [string, Product SKU]
  price: [number, The price of the product]
  class: [string, Additional CSS class names]
---
<product-price class="{{ class }}" sku="{{ sku }}">
  <strong slot="price">${{ price }}</strong>
  <button class="button is-primary" slot="add-to-cart">Add to Cart</button>
</product-price>
```
{% endraw %}

After running `yarn add lit-element` to add LitElement to your Webpack config, add the following Javascript:

`src/_components/product.js`:

```js
import { css, customElement, html, LitElement, property } from "lit-element"
import registry from "../../frontend/javascript/productStockRegistry.js"

@customElement("product-price")
class ProductPrice extends LitElement {
  @property()
  sku = ""

  static styles = css`
    .loading {
      opacity: 0.5;
    }
  `

  // Render the component template to the document DOM
  render() {
    return html`
      <aside class="${!this.productLoaded? "loading" : ""}">
        <div><slot name="price"></slot></div>
        <div>
          ${ this.product.inventory > 0 ?
            html`<slot @click="${this.addToCartHandler}" name="add-to-cart"></slot>` :
            html`We're sorry, this product is currently out of stock.`
          }
        </div>
      </aside>
    `
  }

  // After render, update the text within the price slot
  updated() {
    if (this.product.price) {
      this.querySelector("[slot=price]").textContent = `\$${this.product.price}`
    }
  }

  // Kick off loading the remote product data
  connectedCallback() {
    this.loadProduct()
    super.connectedCallback()
  }

  // Load in the remote product data, then trigger a re-render
  async loadProduct() {
    this.product = {inventory: 1} // initial state
    this.product = await registry.stockForProduct(this.sku)
    this.productLoaded = true
    this.requestUpdate()
  }

  // Event handler for when the Add to Cart button is clicked
  addToCartHandler(e) {
    if (this.productLoaded) {
      // Add the product to the cart! :)
    } else {
      // Uh oh, we don't know if there's real inventory yet
      console.warn("Inventory not yet loaded…")
    }
  }
}
```

(The stock registry object and the API call it makes to retrieve external data is left as an exercise for the reader.)

Finally, to render the Liquid component and thus instantiate the web component on the client side, all you need to do is add this to a Bridgetown page or template:

{% raw %}
```liquid
{% render "product", class: "highlighted", price: product.price, sku: product.sku %}
```
{% endraw %}

In this case, the `product` data would likely come from the same remote API during the Bridgetown build process as what the client side uses.

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
