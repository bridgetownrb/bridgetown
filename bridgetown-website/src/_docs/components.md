---
title: Components
order: 160
top_section: Designing Your Site
category: components
---

Thinking of your website design as a collection of loosely-coupled, independent components which can be placed anywhere, nested, and reused, is one of the most exciting developments in the practice of building for the modern web.

While it's tempting to think of components as applicable to frontend development only (via popular frameworks such as React), component-based design is actually something you can accomplish using SSR (server-side rendering) or static rendering as well, and there are a myriad of ways you can wire up generated component markup served to the browser with frontend dynamism using JavaScript.

Bridgetown provides two mechanisms to do this today, either by using the [Liquid template engine](/docs/template-engines/liquid) or a [Ruby-based template engine such as ERB](/docs/template-engines/erb-and-beyond). Bridgetown even supports a [compatibility shim](https://github.com/bridgetownrb/bridgetown-view-component) for the ViewComponent library by GitHub which has taken the Rails community by storm. One Ruby component library to rule them all? Could be!

So go ahead: pick your preferred component flavor and let's dive in.

<p style="margin-top:2em; display:flex; gap:1em; justify-content:center">
  <a href="/docs/components/liquid">
    <sl-button type="primary" outline>
      Liquid
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
  <a href="/docs/components/ruby">
    <sl-button type="primary" outline>
      Ruby (ERB & Beyond)
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
</p>

## Sidecar Frontend Assets

As part of a component-based design system, you might want to include CSS and/or JavaScript files alongside your components, so that the styles for your components are defined in the same folder structure as the component templates themselves, and any client-side interactivity related to the component is also defined in-place. Here's an example file structure:

```shell
.
├── src
│   ├── _components
│   │   ├── card.liquid
│   │   ├── card.scss
│   │   ├── shared
│   │   │   ├── navbar.erb
│   │   │   ├── navbar.js
│   │   │   ├── navbar.rb
│   │   │   └── navbar.scss
```

Bridgetown comes with a built-in Sass or PostCSS configuration so you can import `.(s)css` files from the `src/_components` folder. In the above example, to import `card.scss` and `shared/navbar.scss` into your stylesheet, add the following to `frontend/styles/index.scss`:

```scss
@import "components.scss"; // in src/_components
```

And then add the imports to the `src/_components/components.scss` file:

```scss
@import "card.scss";
@import "shared/navbar.scss";
```

For JavaScript files, Bridgetown will automatically load all `.js` files in the `src/_components` directory into your bundle.

### Hybrid Components

One of the interesting design patterns that emerges when defining components this way is the interplay between statically-rendered markup and JavaScript-powered interactivity. Unlike static site generators built around client-side technologies such as React, Bridgetown starts you off with the strategic concept that everything originates with "server-rendered" content. What you choose to do with that built HTML _after_ it's presented in the browser is up to you. However, an approach we've come to deeply appreciate is combining a static component with a "web component".

[Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_components) is an open standard, an integral part of the fabric of the web and supported by all modern, evergreen browsers. A web component starts life as a custom element in HTML markup which contains one or more dashes, for example `<my-button>` or `<card-heading-title>`. You then direct the browser to load that custom element as a custom JavaScript object through use of the `window.customElements.define` method. A web component also comes with a suite of features such as Shadow DOM, Slots, and CSS Shadow Parts to give the component a degree of autonomy and clean separation from the styling and markup concerns of the parent document.

While you can author a web component without using libraries or frameworks of any kind, we recommend using a small library called [LitElement](https://lit-element.polymer-project.org) (or even its tinier sibling [lit-html](https://lit-html.polymer-project.org)) which makes web component development as conceptually straightforward as legacy component frameworks such as Vue or React.

By building "default" markup into your static component, and then using a "hydration-like" strategy to enhance the component in JavaScript, you get lightning-fast static markup which works even without JavaScript enabled—while at the same time taking advantage of advanced client-side user interface capabilities. You can also take advantage of APIs to render up-to-date content in real-time in the browser after possibly-stale static content has first loaded.

{%@ Note do %}
  You don't _have_ to use web components to take advantage of this pattern. You can use any light-weight "JavaScript sprinkles" library such as [Stimulus](https://stimulusjs.org) or [Alpine](https://github.com/alpinejs/alpine/) and the concepts remain relatively the same.
{% end %}

Here's an example of a component which shows a product price and an Add to Cart button. We'll first define it as a Liquid component and display the price directly as statically-generated HTML. Then we'll define a LitElement-powered web component which updates the price and checks if the product is in stock before enabling the shopping cart interactivity of the button.

`src/_components/product.liquid`:

{% raw %}
```html
<product-price class="{{ class }}" sku="{{ sku }}">
  <strong slot="price">${{ price }}</strong>
  <button class="button is-primary" slot="add-to-cart">Add to Cart</button>
</product-price>
```
{% endraw %}

After running `yarn add lit-element` to add LitElement to your Webpack config, add the following JavaScript:

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
