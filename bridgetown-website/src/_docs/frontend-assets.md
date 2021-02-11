---
title: Frontend Bundling (CSS/JS/etc.)
order: 17
top_section: Content
category: frontendassets
---

Bridgetown comes with a default configuration of [Webpack](https://webpack.js.org) to handle building and exporting frontend assets such as Javascript/Typescript/etc., CSS/Sass/etc., and related files that are imported through Webpack (fonts, icons, etc.)

Files to be processed by Webpack are placed in the top-level `frontend` folder within your site root. This folder is entirely separate from the Bridgetown source folder where your content, templates, plugins, etc. live. However, using relative paths you can reference files from Webpack that live in the source folder (so you could keep CSS partials alongside Liquid templates, for example).

{% rendercontent "docs/note" %}
Wondering where to save images? Look at the `src/images` folder. You can reference them from both markup and CSS simply using a relative URL (for example, `/images/logo.svg`). Optionally, you can bundle images through Webpack's `css-loader` (more information below). If you're interested in a full-featured image management solution with the ability to resize and optimize your media sizes, check out [Cloudinary](https://www.cloudinary.com){:rel="noopener"} and the [bridgetown-cloudinary plugin](https://github.com/bridgetownrb/bridgetown-cloudinary){:rel="noopener"}.
{% endrendercontent %}

Bridgetown uses [Yarn](https://yarnpkg.com){:rel="noopener"} to install and manage frontend NPM-based packages and dependencies. [Gem-based plugins can instruct Bridgetown](/docs/plugins/gems-and-webpack/) to add a related NPM package whenever Bridgetown first loads the gem.

{% toc %}

## Javascript

The starting place for Javascript code lives at `./frontend/javascript/index.js`. Here you can write your custom functionality, use `import` statements to pull in other modules or external packages, and so forth. This is also where you'd import all relevant CSS. (By default it imports `./frontend/styles/index.scss`.)

Because Bridgetown utilizes standard Webpack functionality, you can trick out your Javascript setup with additional language enhancements like Typescript or add well-known frameworks like [LitElement](https://lit-element.polymer-project.org), [Stimulus](https://stimulusjs.org), [Alpine](https://github.com/alpinejs/alpine/), [React](https://reactjs.org), [Vue](https://vuejs.org), and many others. For example, to add slick page transitions to your website using [Swup](https://swup.js.org/), you would simply run:

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

By default Bridgetown uses [Sass](https://sass-lang.com), a pre-processor for CSS; but you can pass `--use-postcss` to `bridgetown new` to setup `PostCSS` which is popular with the Webpack community.

### Sass

The starting place for CSS code lives at `frontend/styles/index.scss`.

Importing common CSS frameworks such as Bootstrap, Foundation, Bulma and so forth is often as easy as running:

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

### PostCSS

You can run `bridgetown new mysite --use-postcss` to configure your site with PostCSS right out-of-the-box.

The default `PostCSS` config is largely empty so you can set it up as per your preference. The only two plugins included by default are [`postcss-flexbugs-fixes`](https://github.com/luisrudge/postcss-flexbugs-fixes) and [`postcss-preset-env`](https://preset-env.cssdb.org).

If you'd like to use `Sass` with `PostCSS`, you'll need to install a plugin for it:

```shell
$ yarn add @csstools/postcss-sass
```

And then include it at the top of the `plugins` object in `postcss.config.js`:

```js
module.exports = {  
  plugins: {
    '@csstools/postcss-sass': {},
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }
  }
}
```

The popular [TailwindCSS](https://tailwindcss.com) framework can be added to your project by following their [setup guide for PostCSS](https://tailwindcss.com/docs/installation#installing-tailwind-css-as-a-post-css-plugin).

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

## Additional Bundled Assets (Fonts, Images)

By default starting with Bridgetown 0.19.3, both fonts and images can be bundled through Webpack's loaders. This means that, in CSS/JS files, you can reference fonts/images saved somewhere in the `frontend` folder (or even from a package in `node_modules`) and those will get transformed and copied over to `output/_bridgetown` within an appropriate subfolder and with a hashed filename (aka `photo.jpg` would become `photo-31d6cfe0d16ae931b73c59d7e0c089c0.jpg`).

There's a catch with regard to how this works, because you'll also want to be able to save files directly within `src` that are accessible via standard relative URLs (so `src/images/photo.jpg` is available at `/images/photo.jpg` within the static output, no Webpack processing required).

**So here's what you'll want to do:**

* For any files saved inside of `src`, use server-relative paths. For example: `background: url(/images/photo.jpg)` in a frontend CSS file would simply point to what is saved at `src/images/photo.jpg`.
* For any files saved inside of `frontend`, use filesystem-relative paths. For example: `background: url("../images/photo.jpg")` in `frontend/styles/index.css` will look for `frontend/images/photo.jpg`. If the file can't be found, Webpack will throw an error.
* For a Node package file, use Webpack's special `~` character, aka `~package-name/path/to/image.jpg`.

During bundling Webpack will place image files (jpg, png, gif, svg) in `output/_bridgetown/static/images` and font files (woff, woff2, eot, ttf) in `output/_bridgetown/static/fonts`. You can edit `webpack.config.js` if you wish to change this default behavior.

In a future version of Bridgetown, a Liquid tag/Ruby helper will be provided to allow you to reference image URLs via the Webpack manifest, so in theory you could use Webpack to manage _all_ of your image files (instead of saving them in `src`). But for now, Webpack-managed images/fonts are only useful within the context of CSS-based URLs.
