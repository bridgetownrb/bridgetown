---
order: 50
title: Bundled Configurations
top_section: Setup
category: bundledconfigurations
---

Bridgetown bundles a number of automation scripts to set up common project
configurations. You can run these scripts using `bin/bridgetown
configure [CONFIGURATION]`

The configurations we include are:
- [Turbo](#turbo) (`turbo`)
- [Stimulus](#stimulus) (`stimulus`)
- [Lit](#lit) (`lit`)
- [Web Awesome](#web-awesome) (`webawesome`)
- [Open Props](#open-props) (`open-props`)
- [Ruby2JS](#ruby2js) (`ruby2js`)
- [Bridgetown recommended PostCSS plugins](#bridgetown-recommended-postcss-plugins) (`bt-postcss`)
- [PurgeCSS Post-Build Hook](#purgecss-post-build-hook) (`purgecss`)
- [Render YAML Configuration](#render-yaml-configuration) (`render`)
- [Netlify TOML Configuration](#netlify-toml-configuration) (`netlify`)
- [GitHub Pages Configuration](#github-pages-configuration) (`gh-pages`)
- [Automated Test Suite using Minitest](#automated-test-suite-using-minitest) (`minitesting`)
- [Cypress](#cypress) (`cypress`)
- [SEO](#seo) (`seo`)
- [Feed (RSS-like)](#feed) (`feed`)

The full list of configurations can also be seen by running `bridgetown configure` without arguments.

Bundled configurations can also be run while creating a new Bridgetown project using the `--configure=` or `-c` flag and passing in a comma-separated list of configurations.

{%@ Note type: :warning do %}
  #### Looking for Tailwind?

  The bundled configuration for TailwindCSS has been [relocated to a separate community-maintained repo](https://github.com/bridgetownrb/tailwindcss-automation). The Bridgetown core team recommends looking into options such as Open Props, Web Awesome, and otherwise "vanilla" CSS (perhaps with a bit of help from PostCSS) as a best practice for "Use the Platform", future-compatible frontend development.
{% end %}

## Configuration Setup Details

### Turbo

⚡️ Adds and configures [Turbo](https://turbo.hotwired.dev). Turbo gives you the speed of a single-page web application without having to write any additional JavaScript.

🛠 **Configure using:**

```sh
bin/bridgetown configure turbo
```

An optional script (`turbo_transitions.js`) is provided to add transition animation to Turbo navigation. If you don't wish to use any transition animations, you're welcome to delete the file. You can also edit the script to adjust the animation style or change the element being animated from `<main>` to whatever you prefer.

{%@ Note type: :warning do %}
It is recommended you add the `data-turbo-track="reload"` attribute to the `script` and CSS `link` tags in your HTML head. This will allow Turbo to perform a full page reload any time newly-deployed assets are available.
{% end %}

### Stimulus

⚙️ Sets up [Stimulus](https://stimulus.hotwired.dev) and adds an example controller. Stimulus is "the modest JavaScript framework for the HTML you already have."

🛠 **Configure using:**

```sh
bin/bridgetown configure stimulus
```

### Lit

🔥 Sets up [Lit](https://lit.dev) plus the Lit SSR Renderer plugin and adds an example component. Every Lit component is a native web component, with the superpower of interoperability. This makes Lit ideal for building shareable components, design systems, or maintainable, future-ready sites and apps.

🛠 **Configure using:**

```sh
bin/bridgetown configure lit
```

Read our full [Lit Components documentation here](/docs/components/lit).

### Web Awesome

👑 Installs [Web Awesome](https://webawesome.com) for an instant design system and UI component library at your fingertips. Use CSS variables and shadow parts to customize the look and feel of Web Awesome components in any way you like. This very website uses Web Awesome for example.

Individual components can be imported by adding the `import` statement to the `./frontend/javascript/index.js` file. Refer to Web Awesome documentation Importing section for each individual component, and copy the `import` statement under the "npm" tab.

Read more at [Frontend Bundling (CSS/JS/etc.)](/docs/frontend-assets#javascript).

🛠 **Configure using:**

```sh
bin/bridgetown configure webawesome
```

### Open Props

🎨 Installs [Open Props](https://open-props.style), a collection of "supercharged CSS variables" and optional normalize stylesheet to help you create your own design system.

🛠 **Configure using:**

```sh
bin/bridgetown configure open-props
```

### Ruby2JS

🔴 Installs [Ruby2JS](https://www.ruby2js.com), an extensible Ruby to modern JavaScript transpiler you can use in production today. It produces JavaScript that looks hand-crafted, rather than machine generated. You can convert Ruby-like syntax and semantics as cleanly and “natively” as possible. This means that (most of the time) you’ll get a line-by-line, 1:1 correlation between your source code and the JS output.

Write your files in `frontend/javascript` or in `src/_components` with a `.js.rb` extension and they'll be supported the same way as `.js` file by Bridgetown's frontend bundling pipeline.

🛠 **Configure using:**

```sh
bin/bridgetown configure ruby2js
```

### Bridgetown recommended PostCSS plugins

⛓️ Installs and configures a set of [PostCSS](https://postcss.org) plugins recommended by the Bridgetown community:

- [`postcss-mixins`](https://github.com/postcss/postcss-mixins)
- [`postcss-color-mod-function`](https://github.com/csstools/postcss-color-mod-function)
- [`cssnano`](https://cssnano.co)

It will also configure [`postcss-preset-env`](http://preset-env.cssdb.org) to polyfill all features at [stage 2 and above](http://preset-env.cssdb.org/features#stage-2). If you don't need certain polyfills for your use case, you can bump up stage to 3 or 4 *(for example, [`custom properties`](http://preset-env.cssdb.org/features#custom-properties) won't get polyfilled if stage is set to 4)*. [`nesting-rules`](http://preset-env.cssdb.org/features#nesting-rules) and [`custom-media-queries`](http://preset-env.cssdb.org/features#custom-media-queries) are explicitly enabled.

This configuration will overwrite your `postcss.config.js` file.

🛠 **Configure using:**

```sh
bin/bridgetown configure bt-postcss
```

If you'd like to customize your setup further you can find more plugins [here](https://www.postcss.parts).

### PurgeCSS Post-Build Hook

🧼 Adds a builder plugin which runs [PurgeCSS](https://purgecss.com) against the output HTML + frontend JavaScript and produces a much smaller CSS output bundle for sites which use large CSS frameworks. **NOTE:** do not install this if you are also installing Tailwind, as this plugin and the Tailwind JIT will conflict with one another.

🛠 **Configure using:**

```sh
bin/bridgetown configure purgecss
```

### Render YAML Configuration

⚙️ Adds a static site service defined in YAML to your site for use in [Render](https://render.com) deployments.

🛠 **Configure using:**

```sh
bin/bridgetown configure render
```

### Netlify TOML Configuration

⚙️ Adds a basic configuration to your site for use in [Netlify](https://netlify.com) deployments.

🛠 **Configure using:**

```sh
bin/bridgetown configure netlify
```

### GitHub Pages Configuration

⚙️ Sets up a GitHub Action so you can host your Bridgetown site directly on GitHub.

Make sure you follow the provided instructions after you run this command so your `base_path` is configured correctly.

🛠 **Configure using:**

```sh
bin/bridgetown configure gh-pages
```

### Automated Test Suite using Minitest

⚙️ Adds a test suite using [Minitest](https://rubygems.org/gems/minitest) and [Rack::Test](https://github.com/rack/rack-test) which lets you test both static and dynamic routes. Check out [our automated testing guide](/docs/testing#use-ruby-and-minitest-to-test-html-directly) for more information.

🛠 **Configure using:**

```sh
bin/bridgetown configure minitesting
```

### Cypress

⚙️ Installs and sets up [Cypress](https://www.cypress.io/) for browser based end-to-end testing. Check out [our automated testing guide](/docs/testing#headless-browser-testing-with-cypress) for more info!

🛠 **Configure using:**

```sh
bin/bridgetown configure cypress
```

### SEO

🔍 Adds metadata tags for search engines and social networks to better index and display your site's content. Check out the [gem readme](https://github.com/bridgetownrb/bridgetown-seo-tag#summary) for more info and configuration options.

🛠 **Configure using:**

```sh
bin/bridgetown configure seo
```

### Feed

🍽️ Generate an Atom (RSS-like) feed of your Bridgetown posts and other collection documents. Check out the [gem readme](https://github.com/bridgetownrb/bridgetown-feed#usage) for more info and configuration options.

🛠 **Configure using:**

```sh
bin/bridgetown configure feed
```
