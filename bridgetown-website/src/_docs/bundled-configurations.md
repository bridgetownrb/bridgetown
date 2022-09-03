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
- [Shoelace](#shoelace) (`shoelace`)
- [Open Props](#open-props) (`open-props`)
- [Ruby2JS](#ruby2js) (`ruby2js`)
- [Bridgetown recommended PostCSS plugins](#bridgetown-recommended-postcss-plugins) (`bt-postcss`)
- [PurgeCSS Post-Build Hook](#purgecss-post-build-hook) (`purgecss`)
- [Render YAML Configuration](#render-yaml-configuration) (`render`)
- [Netlify TOML Configuration](#netlify-toml-configuration) (`netlify`)
- [Vercel JSON Configuration](#vercel-json-configuration) (`vercel`)
- [GitHub Pages Configuration](#github-pages-configuration) (`gh-pages`)
- [Automated Test Suite using Minitest](#automated-test-suite-using-minitest) (`minitesting`)
- [Cypress](#cypress) (`cypress`)

The full list of configurations can also be seen by running `bridgetown configure` without arguments.

Bundled configurations can also be run while creating a new Bridgetown project using the `--configure=` or `-c` flag and passing in a comma-separated list of configurations.

{%@ Note do %}
  #### Jared's Recommended "Starter Kit"

  The insane amount of productivity this toolset will provide you is off the charts!

  `$ bridgetown new born_to_be_wild -t serbea -c turbo,ruby2js,shoelace,lit,bt-postcss,render`

  Keep reading for documentation on all those options.
{% end %}

{%@ Note type: :warning do %}
  #### Looking for Tailwind?

  The bundled configuration for TailwindCSS has been [relocated to a separate community-maintained repo](https://github.com/bridgetownrb/tailwindcss-automation). The installation process remains just as simple. However, the Bridgetown core team recommends looking into options such as Open Props, Shoelace, and otherwise "vanilla" CSS (perhaps with a bit of help from PostCSS or Sass) as a best practice for "Use the Platform", future-compatible frontend development.
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

### Shoelace

👟 Installs [Shoelace](https://shoelace.style) for an instant design system and UI component library at your fingertips. Use CSS variables and shadow parts to customize the look and feel of Shoelace components in any way you like. This very website uses Shoelace for example.

🛠 **Configure using:**

```sh
bin/bridgetown configure shoelace
```

### Open Props

🎨 Installs [Open Props](https://open-props.style), a collection of "supercharged CSS variables" and optional normalize stylesheet to help you create your own design system.

🛠 **Configure using:**

```sh
bin/bridgetown configure open-props
```

### Ruby2JS

🔴 Installs [Ruby2JS](https://www.ruby2js.com), an extensible Ruby to modern JavaScript transpiler you can use in production today. It produces JavaScript that looks hand-crafted, rather than machine generated. You can convert Ruby-like syntax and semantics as cleanly and “natively” as possible. This means that (most of the time) you’ll get a line-by-line, 1:1 correlation between your source code and the JS output.

Simply write your files in `frontend/javascript` or in `src/_components` with a `.js.rb` extension and they'll be supported the same way as `.js` file by Bridgetown's frontend bundling pipeline.

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

### Vercel JSON Configuration

⚙️ Adds a basic configuration to your site for use in [Vercel](https://vercel.com) deployments along with a builder to ensure Bridgetown uses the correct `absolute_url` on preview deployments.

🛠 **Configure using:**

```sh
bin/bridgetown configure vercel
```

### GitHub Pages Configuration

⚙️ Sets up a GitHub Action so you can host your Bridgetown site directly on GitHub.

Make sure you follow the provided instructions after you run this command so your `base_path` is configured correctly.

🛠 **Configure using:**

```sh
bin/bridgetown configure gh-pages
```

### Automated Test Suite using Minitest

⚙️ Adds a basic test suite using [Minitest](https://rubygems.org/gems/minitest) and Rails DOM assertions for extremely fast verification of your output HTML. Check out [our automated testing guide](/docs/testing#use-ruby-and-minitest-to-test-html-directly) for more info!

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
