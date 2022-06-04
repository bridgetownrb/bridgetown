---
title: Lit Web Components
category: components
top_section: Designing Your Site
order: 0
---

The [Web Component](https://developer.mozilla.org/en-US/docs/Web/Web_components) spec is an open web standard, an integral part of the fabric of the web and supported by all modern, evergreen browsers. A web component starts life as a custom element in HTML markup which contains one or more dashes, for example `<my-button>` or `<card-heading-title>`. You then direct the browser to load that custom element as a dedicated JavaScript object through use of the `window.customElements.define` method. A web component also comes with a suite of features such as Shadow DOM, Slots, and CSS Shadow Parts to give the component a degree of autonomy and clean separation from the styling and markup concerns of the parent document.

While you can author a web component without using libraries or frameworks of any kind, the lightweight [Lit](https://lit.dev) library makes web component development fast & straightforward, offering a fabulous DX (Developer Experience) through features like reactive rendering, attribute reflection as properties (including JSON data!), and template literal syntax.

Through the use of Bridgetown's [Lit Renderer](https://www.github.com/bridgetownrb/bridgetown-lit-renderer) plugin, you can "bake" HTML & CSS from the Lit component into your static or server-rendered output via Declarative Shadow DOM, which is then "re-hydrated" on the client side. You can take advantage of APIs to render up-to-date content in real-time in the browser after possibly-stale static content has first loaded.

{%= toc %}

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

## Take Lit for a Spin

As part of the installation, an example component was provided in `src/_components/happy-days.lit.js`. It looks like this:

```js
import { LitElement, html, css } from "lit"

export class HappyDaysElement extends LitElement {
  static styles = css`
    :host {
      display: block;
      border: 2px dashed gray;
      padding: 20px;
      max-width: 300px;
    }
  `

  static properties = {
    hello: { type: String }
  }

  render() {
    return html`
      <p>Hello ${this.hello}! ${Date.now()}</p>
    `;
  }
}

customElements.define("happy-days", HappyDaysElement)
```

The component establishes some initial styles (`:host` is the way you apply CSS directly to the custom element itself) and configures a `hello` reactive property (which gets initialized with whatever is contained within the `hello` HTML attribute). It then renders out a paragraph tag within its shadow DOM containing the `hello` text and a current timestamp.

You can use this component in any Ruby template (Liquid not supported). For example, in an `.erb` template or page:

```erb
<%= lit :happy_days, hello: "there" %>
```

The helper will know how to convert the tag name and attribute keywords to HTML output via Lit's SSR process. It will look something like this:

```html
<hydrate-root>
  <happy-days defer-hydration hello="there">
    <template shadowroot="open">
      <style>
        :host {
          display: block;
          border: 2px dashed gray;
          padding: 20px;
          max-width: 300px;
        }
      </style>
      <p>Hello there! 1654106939801</p>
  </happy-days>
</hydrate-root>
```

The `<hydrate-root>` custom element is provided by Bridgetown's Lit plugin and establishes the "island" of the the Lit component tree for re-hydration upon page load. Within the `<happy-days>` component, the `<template shadowroot="open">` tag contains the rendered content as part of the declarative shadow DOM spec.

Once you start up your Bridgetown site and visit the page, you should see a box containing "Hello there!" and a timestamp when the page was first rendered.

You can reload the page several times and see that the timestamp doesn't change, because Lit's SSR + Hydration support knows not to re-render the component. However, if you change the `hello` attribute, you'll get a re-render and thus see a new timestamp. _How cool is that?!_

## Lit Helper Options

The `lit` helper works in any Ruby template language and let's you pass data down to the Lit SSR build process. Any value that's not already a string will be converted to JSON (via Ruby's `to_json`). You can use a symbol or string for the tag name and underscores are automatically converted to dashes.

```erb
<%= lit :page_header, title: resource.data.title %>
```

(Remember, all custom elements always must have at least one dash within the HTML.)

If you pass a block to `lit`, it will add that additional HTML into the Lit template output:

```erb
<%= lit :ui_sidebar do %>
  <h2 slot="title">Nice Sidebar</h2>
<% end %>
```

You can also pass page/resource front matter and other data along via the `data` keyword, which then can be used in the block. In addition, if a tag name isn't present, you can add it yourself in within the block.

```erb
<%= lit data: resource.data do %>
  <page-header>
    <h1>${data.title}</h1>
  </page-header>
<% end %>
```

When the component is hydrated, it will utilize the same data that was passed at build time and avoid a client-side re-render. However, from that point forward you're free to mutate component attribute/properties to trigger re-renders as normal. [Check out Lit's `firstUpdated` method](https://lit.dev/docs/components/lifecycle/#reactive-update-cycle-completing) as a good place to start.

You also have the option of choosing a different entry point (aka your JS file that contains or imports one or more Lit components). The default is `./config/lit-components-entry.js`, but you can specify any other file you wish (the path should be relative to your project root).

```erb
<%= lit data: resource.data, entry: "./frontend/javascript/components/headers.js" do %>
  <page-header title="${data.title}"></page-header>
<% end %>
```

This would typically coincide with a strategy of having multiple esbuild/Webpack entry points, and loading different entry points on different parts of your site. An exercise left for the reader…

## Sidecar CSS Files

The "default" manner in which you author styles in Lit components is to use `css` tagged template literals (as you saw in the `happy-days` example above). However, some people prefer authoring styles in dedicated CSS files. The [esbuild-plugin-lit-css](https://github.com/bennypowers/lit-css/tree/main/packages/esbuild-plugin-lit-css) plugin allows you to author perfectly vanilla CSS files alongside your component files and import them.

{%@ Note do %}
  One major benefit to this approach is it allows you to process your component CSS through [PostCSS](/docs/frontend-assets#postcss) using the same configuration and plugins as for other CSS files.
{% end %}

In order to separate the "globally-accessible" stylesheets you may have in `src/_components` from the Lit component-specific stylesheets (which we only want to get instantiated within component shadow roots), we'll need to use the following file conventions:

* For global stylesheets, use a `.global.css` suffix.
* For Lit component stylesheets, use a `.lit.css` suffix.

Bridgetown's bundled Lit configuration provides the building blocks for this setup. You'll need to edit a few lines in your `frontend/javascript/index.js` and `esbuild.config.js` files to opt into this (just look at the comments in the files). Once completed, you'll be able to write components such as this:

```js
// _src/components/my-nifty-tag.lit.js
import { LitElement, html } from "lit"

import style from "./my-nifty-tag.lit.css" assert { type: "css" }

export class MyNiftyTag extends LitElement {
  static styles = [style]

  // rest of the component definition here
}

customElements.define("my-nifty-tag", MyNiftyTag)
```

You can even combine external stylesheets with ones defined directly within a component if you need to share styles between multiple components.

```js
import { LitElement, html } from "lit"

import style from "./shared/components.lit.css" assert { type: "css" }

export class ManyStylesElement extends LitElement {
  static styles = [
    style,
    css`
      :host {
        border: 1px solid var(--gray-5);
        max-width: 80ch;
      }
    `
  ]

  // …
}
```

{%@ Note do %}
  While the esbuild Lit CSS plugin doesn't _require_ you to include `assert { type: "css" }` at the end of your import statements, it's a good idea to get in the habit as it aligns your code with the [CSS Module Scripts](https://web.dev/css-module-scripts/) spec rolling out to browsers now and in future.
{% end %}

## In Combination with Ruby Components

A very powerful pattern for Bridgetown component design is to use a Lit component _as the template_ for a Ruby component. This allows you to use the Ruby component anywhere on your site, along with any pre-processing of data you need it to perform, and then the Ruby component can "emit" a Lit web component upon render. As an example:

```rb
class MyRubyComponent < Bridgetown::Component
  def initialize(value:)
    @value = process_value(value)
  end

  def process_value
    @value = "Value: #{@value}"
  end

  def template
    lit :my_lit_component, value: @value
  end
end
```

```erb
<!-- elsewhere -->
<%= render MyRubyComponent.new(value: "Here is my value") %>
```

In this example, you wouldn't need a sidecar template for your component in ERB or whatever, because the Lit component serves as the template.

## Technical and Performance Considerations

With a bit of careful planning of which entry point(s) you use, the data you provide, and the structure of your HTML markup within the `lit` helper, you can achieve good Lit SSR performance while still taking full advantage of the Ruby templates and components you know and love.

More documentation on this is [available in the plugin README](https://www.github.com/bridgetownrb/bridgetown-lit-renderer#readme).
