---
title: Frontend Assets (Webpack)
order: 16
top_section: Content
category: frontendassets
---

{% render "docs/help_needed", page: page %}

Bridgetown comes with a default configuration of [Webpack](https://webpack.js.org) to handle building and exporting frontend assets such as Javascript/Typescript/etc., CSS/Sass/etc., and related files that are imported through Webpack (fonts, icons, etc.)

Files to be processed by Webpack are placed in the top-level `frontend` folder within your site root. This folder is entirely separate from the Bridgetown source folder where your content, templates, plugins, etc. live. However, using relative paths you can reference files from Webpack that live in the source folder (so you could keep CSS partials alongside Liquid templates, for example).

Bridgetown uses [Yarn](https://yarnpkg.com) to install and manage frontend NPM-based
packages and dependencies.
[Gem-based plugins can instruct Bridgetown](/docs/plugins/gems-and-webpack/) to add
a related NPM package whenever Bridgetown first loads the gem.

## Javascript

The starting place for Javascript code lives at `./frontend/javascript/index.js`. Here you can write your custom functionality, use `import` statements to pull in other modules or external packages, and so forth. This is also where you'd import all relevant CSS. (By default it imports `./frontend/styles/index.scss`.)

Because Bridgetown utilizes standard Webpack functionality, you can trick out your Javascript setup with additional language enhancements like Typescript or add well-known frameworks like React, Vue, Stimulus, and many others. For example,
to add slick page transitions to your website using [Swup](https://swup.js.org/), you would simply run:

```sh
yarn add swup
```

And then update `./frontend/javascript/index.js` with:

```js
import Swup from "swup"

const swup = new Swup()
```

And the update your HTML layout according to the Swup install guide.

## CSS

The starting place for CSS code lives at `./frontend/styles/index.scss`. By default Bridgetown uses [Sass](https://sass-lang.com), a pre-processor for CSS, but you can customize your Webpack config to change that to use standard `PostCSS` which is popular with the Webpack community.

Importing common CSS frameworks such as Bootstrap, Foundation, Bulma, Tailwind, and so forth is often as easy as running:

```shell
$ yarn add name-of-css-framework
```

And then adding:

```css
@import "~css-framework/css-framework";
```

to `index.scss`. For example, to add [Bulma](https://bulma.io) which is a modern CSS-only (no Javascript) framework built around Flexbox, you'd simply run:

```shell
$ yarn add bulma
```

and then add:

```css
@import "~bulma/bulma";
```

to `index.scss`.

## Linking to the Output Bundles

Bridgetown's default Webpack configuration is set up to place all compiled output into the `_bridgetown` folder in your `output` folder. Bridgetown knows when it regenerates a website not to touch anything in `_bridgetown` as that comes solely from Webpack. It is recommended you do not use the site source folder to add anything to `_bridgetown` as that will not get cleaned and updated by Bridgetown's generation process across multiple builds.

To reference the compiled JS and CSS files from Webpack in your site template, simply add the `webpack_path` Liquid tag to your HTML `<head>`:

{% raw %}
```liquid
<link rel="stylesheet" href="{% webpack_path css %}" />
<script src="{% webpack_path js %}" defer></script>
```
{% endraw %}

This will automatically produce HTML tags that look something like this:

```html
<link rel="stylesheet" href="/_bridgetown/static/css/all.6902d0bf80a552c79eaa.css"/>
<script src="/_bridgetown/static/js/all.a1286aad43064359dbc8.js" defer></script>
```
