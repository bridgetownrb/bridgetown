---
title: Islands Architecture
order: 260
top_section: Architecture
category: islands
---

The term [Islands Architecture](https://jasonformat.com/islands-architecture) was coined a few years ago by frontend architect Katie Sylor-Miller and further popularized by Preact creator Jason Miller. It describes a way of architecting website frontends around independent component trees, all rendered server-side initially as HTML but then "hydrated" on the frontend independently of one another.  

In Bridgetown, **we've brought islands architecture to you** with a seamless integration between our [view components](/docs/components) and our [esbuild frontend bundling system](/docs/frontend-assets). And for even more flexibility, you can orient your Roda routes around "islands" for a truly modular, full-stack approach to web development.

Islands architecture is constantly evolving, so your feedback is crucial as we increasingly align our best practices with the latest improvements across the industry.

{{ toc }}

## Creating Your First Island

If you've just created a new Bridgetown project, you're ready to take it to the next level. If you're upgrading from Bridgetown 1.2 or previous, you'll need to be using esbuild (not Webpack) and must update your base esbuild configuration. It's a snap! Just run:

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

Next, in the `src/_islands` folder (please create one if it's not already present), add your first island "entrypoint" which we'll call `breezy.js`:

```js
class BreezyDay extends HTMLElement {
  static {
    customElements.define("breezy-day", this)
  }
  
  connectedCallback() {
    this.textContent = "Welcome to your first island."
  }
} 
```

This JavaScript file, and anything else you import through it, is contained to a single island, meaning it won't be bundled in with your main JavaScript bundle (aka `frontend/javascript/index.js`). Great! But how do you _load_ an island?

With `<is-land>`, of course!

## Installing the Island

Bridgetown comes with a [bundled configuration](/docs/bundled-configurations) to set up the `<is-land>` web component, [a tiny package](https://is-land.11ty.dev) which lets you _lazy-load_ islands just as they become visible on-screen or are interacted with (aka clicked).

Run this command to add it to your main JavaScript bundle:

```shell
bin/bridgetown configure is-land
```

Now let's add the island to a page. Pick one of the pages on your site (it needs to be ERB for the purposes of this example) and add this bit of code:

```erb
<is-land on:visible import="<%= asset_path 'islands/breezy.js' %>">
  <breezy-day>
    Approaching the island. . .
  </breezy-day>
</is-land>
```

Let's break this down:

1. The `<is-land>` tag gets set up to import the new `breezy.js` island you've created once it's visible to the reader.
2. At first the `<breezy-day>` element will be undefined, but once the island loads, it will be upgraded/hydrated.
3. Once that moment occurs, the "Approaching…" text will get replaced with "Welcome…". That's just a simple example—more likely you'd want to write your island JavaScript to set up event handlers, or display more up-to-the-second data pulled from an API, etc.

## Rendering Island Components in Ruby

Generally we wouldn't recommend directly adding your island markup inside of `<is-land>` on any given page, but rather render a component tree of one or more components you define. For this purpose, we've included `src/_islands` as a folder which can load Ruby components. And by using folder-based namespaces, you can easily keep island-specific components separated.

Let's move `<breezy-day>` into its own Ruby component. We'll create a new `src/_islands/breezy_day` folder and add the namespaced `Element` class to `element.rb`:

```ruby
class BreezyDay::Element < Bridgetown::Component
  attr_reader :fallback

  def initialize(fallback: "Approaching the island. . .")
    @fallback = fallback
  end
end
```

And then define our `element.erb` template:

```erb
<breezy-day>
  <%= fallback %>
</breezy-day>
```

Now in our original page template code, we can simply render the component and that's that.

```erb
<is-land on:visible import="<%= asset_path 'islands/breezy.js' %>">
  <%= render BreezyDay::Element.new %>
</is-land>
```

You can of course render shared components from `src/_components` from  your island component as well, along with other island-specific components you may define.

## Scoped Styling via Declarative Shadow DOM (DSD)

For many (most?) islands, you'll want to provide styles as part of your markup. We strongly recommend using shadow DOM inside your web components, and our [native DSD support](/docs/content/dsd) makes this a breeze! (Pardon the pun!)

Let's add some styling to our `<breezy-day>` component via DSD. Edit your `element.erb` as so:

```erb
<breezy-day>
  <%= dsd do %>
    <slot></slot>
    <%= dsd_style %>
  <% end %>
  <%= fallback %>
</breezy-day>
```

And add a stylesheet as `element.dsd.css`:

```css
:host {
  display: block;
  color: LightSeaGreen;
  font-weight: bold;
}
```

Now when you view the page, your island element will appear with the styled color and bold text.

What's great about this approach is (a) only this element is affected by your stylesheet and nothing else on your page, and (b) these styles aren't loaded _until_ the page containing your island is viewed, keeping your main CSS bundle size low. For more general information on how to use and style your HTML templates and components using shadow DOM, check out our [documentation on DSD](/docs/content/dsd).

{%@ Note do %}
The `<is-land>` web component automatically polyfills DSD, which is an added benefit of using it. Otherwise, the Turbo bundled configuration also includes a site-wide polyfill for DSD. As of the time of this writing, only some older versions of Safari and Firefox do not offer built-in DSD support.
{% end %}

{%@ Note type: :warning do %}
Sidecar CSS files processed through the `dsd_style` helper do not get run through PostCSS—aka they must be 100% "vanilla" CSS. Don't be surprised if you try using a feature that's uniquely enabled by your PostCSS config and it's not available within the DSD template.
{% end %}

## Routes in Islands

When using the `bridgetown-routes` plugin for server rendering, you can put file-based routes inside of islands. Just add a `routes` folder inside of an island folder (like the `src/_islands/breezy_day` example above), and then any routes inside will resolve to a URL of the island name plus the route name. Read our [Routes documentation](/docs/routes) for more information.
