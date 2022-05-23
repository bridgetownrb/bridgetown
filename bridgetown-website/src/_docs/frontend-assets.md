---
title: Frontend Bundling (CSS/JS/etc.)
order: 170
top_section: Designing Your Site
category: frontendassets
---

For modern websites, the output of HTML content is only part of the story. You also need a way to manage CSS, JavaScript, fonts, icons, and other frontend assets in a way that's performant, optimized, and hassle-free.

Bridgetown provides such an integrated frontend bundling system. In fact, Bridgetown provides two: **esbuild** and **Webpack**.

By default, Bridgetown will set up a new site using esbuild. If you prefer to use Webpack, you can pass the `--frontend-bundling=webpack` (alias `-e webpack`) option to `bridgetown new`.

You can read more about [esbuild](https://esbuild.github.io) and [Webpack](https://webpack.js.org) on their respective documentation sites.

{{ toc }}

## Frontend Locations

Files to be processed by esbuild or Webpack are placed in the top-level `frontend` folder within your site root. This folder is entirely separate from the Bridgetown source folder where your content, templates, plugins, etc. live. However, using relative paths you can reference files in your frontend that live in the `src` folder (so you can place component-scoped JS/CSS files alongside Liquid or Ruby templates, for example).

{%@ Note do %}
Wondering where to save images? Look at the `src/images` folder. You can reference them from both markup and CSS simply using a relative URL (for example, `/images/logo.svg`). Optionally, you can bundle images through esbuild/Webpack and reference them with the `asset_path` helper (more information below). If you're interested in a full-featured image management solution with the ability to resize and optimize your media sizes, check out [Cloudinary](https://www.cloudinary.com) and the [bridgetown-cloudinary plugin](https://github.com/bridgetownrb/bridgetown-cloudinary).
{% end %}

Bridgetown uses [Yarn](https://yarnpkg.com) to install and manage frontend NPM-based packages and dependencies. [Gem-based plugins can instruct Bridgetown](/docs/plugins/gems-and-frontend/) to add a related NPM package whenever Bridgetown first loads the gem.

## JavaScript

The starting place for JavaScript code lives at `./frontend/javascript/index.js`. Here you can write your custom functionality, use `import` statements to pull in other modules or external packages, and so forth. This is also where you'd import the CSS entrypoint as well to be processed through esbuild or Webpack.

JS files placed anywhere inside `src/_components` are automatically imported and bundled as well.

Because Bridgetown utilizes standard ES bundler functionality, you can trick out your JavaScript setup with additional language enhancements and libraries like Ruby2JS, Lit, Turbo, Shoelace, and many others. And for automated installation of the aforementioned libraries in particular, check out our [Bundled Configurations](/docs/bundled-configurations).

{%@ Note do %}
  #### What about TypeScript?

  TypeScript is one of the many transpile-to-JavaScript languages available today. TypeScript code isn't directly compatible with native JavaScript environments and always requires a build step. It's main selling point is static type-checking. However, it's possible to use type-checking and gain the secondary benefits of documentation popups and project navigation using JSDoc in vanilla JavaScript! In fact, simply by adding `// @ts-check` to the top of a `.js` file, VSCode for example will immediately provide TypeScript-like features as you author your code.

  Bridgetown happily endorses JSDoc-enhanced JavaScript for a 100% ES spec-compatible development environment. [You can learn more about this approach on the TypeScript website.](https://www.typescriptlang.org/docs/handbook/intro-to-js-ts.html)
{% end %}

## CSS

By default Bridgetown comes with support for [PostCSS](https://postcss.org) to allow for cutting-edge/upcoming CSS features which aren't yet supported in all browsers (such as variable-based media queries and selector nesting).

You can also choose to use [Sass](https://sass-lang.com), a pre-processor for CSS. Pass `--use-sass` to `bridgetown new` to set up your project to support Sass.

The starting place for CSS code lives at `frontend/styles/index.css`. You can add additional stylesheets and `@import` them into `index.css`. CSS files placed anywhere inside `src/_components` are automatically imported.

### PostCSS

The default `PostCSS` config is largely empty so you can set it up as per your preference. The only two plugins included by default are [`postcss-flexbugs-fixes`](https://github.com/luisrudge/postcss-flexbugs-fixes) and [`postcss-preset-env`](https://preset-env.cssdb.org).

There's also a [Bundled Configuration](/docs/bundled-configurations#bridgetown-recommended-postcss-plugins) you can run to install recommended PostCSS plugins and set up specific useful features like nesting.

{%@ Note do %}
  #### All the stylesheet’s a stage…

  By default, Bridgetown configures the postcss-preset-env **stage** to be **2**, but you may want to change it to **3** or even **4** for a more compact and performant stylesheet which the latest modern browsers can interpret. The lower the stage number, the more transformations/polyfills PostCSS will run in order to build a widely-compatible stylesheet. You can also determine which individual features to polyfill by adding the `features` option. [Read the postcss-preset-env documentation here](https://www.npmjs.com/package/postcss-preset-env#options) or [browse the list of features here](https://preset-env.cssdb.org/features).
{% end %}

### Sass

The starting place for Sass code lives at `frontend/styles/index.scss`.

Importing common CSS frameworks such as Bootstrap, Foundation, Bulma and so forth is often as easy as running:

```shell
$ yarn add name-of-css-framework
```

And then adding:

```css
@import "~css-framework/css-framework";
```

to `index.scss`. For example, to add [Bulma](https://bulma.io) which is a modern CSS-only (no JavaScript) framework built around Flexbox, you'd simply run:

```shell
$ yarn add bulma
```

and then add:

```css
@import "~bulma/bulma";
```

to `index.scss`.

Or if you'd like to add [Bootstrap](https://getbootstrap.com):

```shell
$ yarn add bootstrap
```

```css
@import "~bootstrap/scss/bootstrap.scss";
```

## Linking to the Output Bundles

Bridgetown's default esbuild/Webpack configuration is set up to place all compiled output into the `_bridgetown` folder in your `output` folder. Bridgetown knows when it regenerates a website not to touch anything in `_bridgetown` as that comes solely from the frontend bundler. It is recommended you do not use the site source folder to add anything to `_bridgetown` as that will not get cleaned and updated by Bridgetown's generation process across multiple builds.

To reference the compiled JS and CSS files from the frontend bundler in your site template, simply add the `asset_path` Liquid tag or Ruby helper to your HTML `<head>`. For example:

{% raw %}
```liquid
<link rel="stylesheet" href="{% asset_path css %}" />
<script src="{% asset_path js %}" defer></script>
```
{% endraw %}

This will automatically produce HTML tags that look something like this:

```html
<link rel="stylesheet" href="/_bridgetown/static/css/all.6902d0bf80a552c79eaa.css"/>
<script src="/_bridgetown/static/js/all.a1286aad43064359dbc8.js" defer></script>
```

## Additional Bundled Assets (Fonts, Images)

Both fonts and images can be bundled through esbuild or Webpack's loaders. This means that, in CSS/JS files, you can reference fonts/images saved somewhere in the `frontend` folder (or even from a package in `node_modules`) and those will get transformed and copied over to `output/_bridgetown` with a hashed filename (aka `photo.jpg` would become `photo-31d6cfe0d16ae931b73c59d7e0c089c0.jpg`).

There's a catch with regard to how this works, because you'll also want to be able to save files directly within `src` that are accessible via standard relative URLs (so `src/images/photo.jpg` is available at `/images/photo.jpg` within the static output, no frontend bundler processing required).

**So here's what you'll want to do:**

* For any files saved inside of `src`, use server-relative paths. For example: `background: url(/images/photo.jpg)` in a frontend CSS file would simply point to what is saved at `src/images/photo.jpg`.
* For any files saved inside of `frontend`, use filesystem-relative paths. For example: `background: url("../images/photo.jpg")` in `frontend/styles/index.css` will look for `frontend/images/photo.jpg`. If the file can't be found, esbuild/Webpack will throw an error.
* When using Webpack in particular, for a Node package file use can Webpack's special `~` character, aka `~package-name/path/to/image.jpg`.

You can use the `asset_path` Liquid tag/Ruby helper to reference assets within the `frontend` folder:

{% raw %}
```liquid
<img src="{% asset_path images/folder/somefile.png %}" />
```

will look for `frontend/images/folder/somefile.png`.

## esbuild Setup

The default configuration is defined in `config/esbuild.defaults.js`. However, you should add or override your own config options in the top-level `esbuild.config.js` file. By modifying the `esbuildOptions` object (blank by default), it adds to or overrides default config options. This provides a straightforward way of adding esbuild plugins and other esbuild features unique to your frontend.

For instance, you could add [Ruby2JS](https://www.ruby2js.com/) support and switch to using a `.js.rb` file for your entrypoint:

```js
const ruby2js = require("@ruby2js/esbuild-plugin")

const esbuildOptions = {
  entryPoints: ["frontend/javascript/index.js.rb"],
  target: "es2020",
  plugins: [
    ruby2js({
      eslevel: 2020,
      filters: ["camelCase", "functions", "lit", "esm", "return"]
    }),
  ]
}
```

{% endraw %}

{%@ Note do %}
  Check out the [Ruby2JS Bundled Configuration](/docs/bundled-configurations#ruby2js) for an automated way to install Ruby2JS.
{% end %}

### Multiple Entry Points

You can specify multiple entry points (which result in multiple output bundles) by using a custom `entryPoints` config. You can then reference the additional entry points using the `asset_path` Liquid tag or Ruby helper. (Be sure to start with `javascript` in your relative paths.) For example:

{% raw %}
```js
// esbuild.config.js

const esbuildOptions = {
  entryPoints: [
    "frontend/javascript/index.js",
    "frontend/javascript/pages/contact_form.js"
  ],
  format: "esm"
}
```

```liquid
<script src="{% asset_path javascript/pages/contact_form.js %}"></script>
```

By also adding `format: "esm"`, you gain the ability to import code from new entry points directly inside of `type="module"` scripts in your HTML! Let's say `contact_form.js` exports the function `contactForm` to set up a form dynamically. Instead of using a `script src=` tag in the HTML head, you could do this (using ERB in this example):

```erb
<script type="module">
  import { contactForm } from "<%= asset_path 'javascript/pages/contact_form.js' %>"

  contactForm("contact-form")
</script>

<form id="contact-form">
</form>
```

### Code Splitting

Another option for "breaking up the bundle" is to dynamically import new code within the execution of your JavaScript code at runtime. To enable this, make sure your esbuild config has these two options:

```js
const esbuildOptions = {
  format: "esm",
  splitting: true,

  // other options here…
}
```

Then replace the `defer` attribute in your HTML head with `type="module"` to ensure your primary JavaScript bundle is loaded as an ES module by the browser. For example:

```
<script src="<%= asset_path :js %>" type="module"></script>
```

Now you can dynamically and asynchronously import JavaScript code within any function:

```js
const loadStuff = async () => {
  const importantStuff = await import("important_stuff.js")
  return importantStuff.default()
}

const doStuff = async () => {
  const justDoIt = await loadStuff()
  justDoIt("Don't let your dreams be dreams!")
}
```
{% endraw %}

You can learn more about [dynamic imports on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import#dynamic_imports).

{%@ Note type: :warning do %}
  ES Module imports have been supported in all modern browsers since 2019, but if you wish to preserve backwards compatibility with older browsers, you'll need to avoid using this technique. 
{% end %}

## Webpack Setup

The default configuration is defined in `config/webpack.defaults.js`. However, you should add or override your own config options in the top-level `webpack.config.js` file.

The default configuration can be updated to the latest version provided by Bridgetown using the `webpack` CLI tool:

```shell
bin/bridgetown webpack update
```

All options provided by the `webpack` CLI tool can be viewed by running:
```shell
bin/bridgetown webpack
```

### Multiple Entry Points

If you need to manage more than one Webpack bundle, you can add additional entry points to the `webpack.config.js` file. For example:

```js
  config.entry.somethingElse = "./frontend/otherscript/something_else.js"
```

Then simply reference the entry point filename via `asset_path` wherever you'd like to load it in your HTML:

{% raw %}
```liquid
<script src="{% asset_path something_else.js %}"></script>
```
{% endraw %}
