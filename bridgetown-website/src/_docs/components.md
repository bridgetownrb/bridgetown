---
title: Components
order: 160
top_section: Designing Your Site
category: components
---

Thinking of your website design as a collection of loosely-coupled, independent components which can be placed anywhere, nested, and reused, is one of the most exciting developments in the practice of building for the  web.

Component-based design systems are at the forefront of major leaps forward in the architecture used to enable agile, scalable codebases. Techniques such as "island architecture" and "hydration" have entered into the modern vernacular. We increasingly see the shift from "page-level" to "component-level" thinking as projects unfold.

Just as a web page can be thought of as the interconnected product of the three primary web technologies (HTML, CSS, & JavaScript), components are themselves individual products made out of those three technologies—or for simpler components, perhaps just one or two. Components also carry with them the concept of a "lifecycle". Understanding the lifecycle of a component on both the backend (SSR & SSG) and the frontend—and perhaps the component's "children" as well—is crucial in determining which toolset you should use to build the component. This touches on the concept we like to call "progressive generation". ([Read our tech specs intro for additional context.](/docs#more-about-the-tech-specs))

**Bridgetown provides three environments for writing components:**

### [Liquid](/docs/components/liquid)

Use the [Liquid template engine](/docs/template-engines/liquid) to write simple components without a lot of custom logic or for maximum compatibility with all template engines. Liquid components are not recommended when complexity is required for frontend logic.

### [Ruby](/docs/components/ruby)

Use a [Ruby-based template engine](/docs/template-engines/erb-and-beyond) in conjunction with a dedicated Ruby class to facilitate more comprehensive scenarios and take full advantage of Ruby's feature set and object-oriented nature. Bridgetown also supports a compatibility shim for the ViewComponent library, a popular Rails extension created by GitHub.

### [Lit (Web Components)](/docs/components/lit)

After installing the Lit Renderer plugin, you can write "hybrid" components which support both a backend lifecycle (during SSG & SSR) and a frontend lifecycle (via Hydration). This technique is recommended for components which must support a high degree of interactivity or data timeliness. You can also take full advantage of web component APIs such as the "shadow DOM" for encapsulated styling (meaning your component styles won't "leak out" and accidentally effect other parts of the website).

So pick your flavor and dive in, or keep reading for more conceptual overview of Bridgetown's component architecture.

## The Subtle Interplay of HTML, CSS, & JavaScript

As previously mentioned, a component will often encompass not just the output HTML coming from the component's logic/template, but styling via CSS, and client-side interactivity via JavaScript.

In those cases, where you place your CSS and JS code will vary depending on the environment. For Liquid and Ruby components, you will write what are called "sidecar" files which live alongside your component classes/templates. In contrast, Lit components fall under the category of Single-File Components. The logic, template, and styling is all part of the same unit of code. Lit components can be written in either vanilla JavaScript or Ruby2JS (a Ruby-like syntax and set of idioms which then transpiles to JavaScript). However, with a smidge of extra configuration, you do have the option of splitting the CSS of a Lit component out to its own sidecar file if you so choose.

Here's an example file structure showing all three environments in use:

```shell
.
└── src
    └── _components
        ├── blog_entry.liquid
        ├── products
        │   ├── buy-now.lit.js
        │   ├── buying.rb
        │   ├── product-cart.lit.css
        │   └── product-cart.lit.js
        └── shared
            ├── navbar.erb
            ├── navbar.js
            ├── navbar.rb
            └── navbar.global.css
```

A rundown of the various component types:

* The "blog entry" component is a single `.liquid` file. Even though it only outputs HTML, we still call this a component because the none of the outside variables of any other template or component can be accessed or mutated. You must pass all necessary data into the component it needs to render content.
* The `buy-now` and `product-cart` components are both Lit-powered web components. The cart component uses a sidecar CSS file. There's also a `Products::Buying` Ruby component which serves as a "wrapper" to the buy now component.
* The `Shared::Navbar` component is a Ruby component with a sidecar ERB template, a modest bit of JavaScript logic (not a web component), and CSS meant to be included in the global stylesheet bundle.

Now let's talk about the lifecycle of these components.

* The Liquid component's lifecycle is static-only. The HTML is rendered out during the build process and that's it.
* The `Shared::Navbar` Ruby component starts out as static HTML + global CSS, and the lifecycle is then extended on the client by JavaScript code which can perform tasks such as attach event handlers or highlight certain items based on real-time navigational changes.
* The Lit components offer true hybrid lifecycles. They are written in JavaScript (or Ruby2JS) and are initially rendered as part of the build process (and thus present in the output HTML) by the Lit Renderer plugin, using an emerging spec called Declarative Shadow DOM. The components are then "hydrated" on the client-side so they can manage state, offer interactivity, and re-render as needed.

Regarding that last item, due to various performance concerns both on the static-build/server-side and the client-side, it should be noted that you likely wouldn't want pepper pages with dozens (or hundreds!) of Lit component renders. Instead you'd want to create what's called an "island" within your page, using the `lit` helper. You can read more about this on the Lit components page.

Ready to dive more into a particular component flavor? Let's go!

<p style="margin-top:2em; display:flex; gap:1em; justify-content:center">
  <a href="/docs/components/liquid">
    <sl-button type="primary" outline>
      Liquid
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
  <a href="/docs/components/ruby">
    <sl-button type="primary" outline>
      Ruby
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
  <a href="/docs/components/lit">
    <sl-button type="primary" outline>
      Lit
      <sl-icon slot="suffix" library="remixicon" name="system/arrow-right-s-fill"></sl-icon>
    </sl-button>
  </a>
</p>
