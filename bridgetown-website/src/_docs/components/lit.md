---
title: Lit Web Components
category: components
top_section: Designing Your Site
order: 0
---

The [Web Component](https://developer.mozilla.org/en-US/docs/Web/Web_components) spec is an open web standard, an integral part of the fabric of the web and supported by all modern, evergreen browsers. A web component starts life as a custom element in HTML markup which contains one or more dashes, for example `<my-button>` or `<card-heading-title>`. You then direct the browser to load that custom element as a custom JavaScript object through use of the `window.customElements.define` method. A web component also comes with a suite of features such as Shadow DOM, Slots, and CSS Shadow Parts to give the component a degree of autonomy and clean separation from the styling and markup concerns of the parent document.

While you can author a web component without using libraries or frameworks of any kind, the [Lit](https://lit.dev) library makes web component development as conceptually straightforward as legacy component frameworks, offering a fabulous DX (Developer Experience) through features like reactive rendering, attribute reflection as properties (including JSON data!), and template literal syntax.

Through the use of Bridgetown's [Lit Renderer](https://www.github.com/bridgetownrb/bridgetown-lit-renderer) plugin, you can "bake" HTML & CSS from the Lit component into your static or server-rendered output via Declarative Shadow DOM, which is then "re-hydrated" on the client side. You can take advantage of APIs to render up-to-date content in real-time in the browser after possibly-stale static content has first loaded.

{% toc %}

## Installing Lit Renderer

Simply run the Bundled Configuration automation:

```sh
$ bin/bridgetown configure lit
```

Or pass it along to the `new` command:

```sh
$ bridgetown new mysite -t erb -c lit
```

This will install both the Lit library itself plus the Lit Renderer plugin.

…
…

## A More Advanced Example

REWRITE !!!

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
