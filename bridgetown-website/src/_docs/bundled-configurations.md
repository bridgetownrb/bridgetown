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
- [TailwindCSS](#tailwindcss) (`tailwindcss`)
- [PurgeCSS Post-Build Hook](#purgecss-post-build-hook) (`purgecss`)
- [Bridgetown recommended PostCSS plugins](#bridgetown-recommended-postcss-plugins) (`bt-postcss`)
- [Render YAML Configuration](#render-yaml-configuration) (`render`)
- [Netlify TOML Configuration](#netlify-toml-configuration) (`netlify`)
- [Vercel JSON Configuration](#vercel-json-configuration) (`vercel`)
- [Automated Test Suite using Minitest](#automated-test-suite-using-minitest) (`minitesting`)
- [Cypress](#cypress) (`cypress`)

The full list of configurations can also be seen by running `bridgetown configure` without arguments.

Bundled configurations can also be run while creating a new Bridgetown project using the `--configure=` or `-c` flag and passing in a comma-separated list of configurations.

```sh
bridgetown new my_project -c turbo,purgecss
```

## Configuration Setup Details

### Turbo

⚙️ Adds and configures [Turbo](https://turbo.hotwired.dev).

🛠 **Configure using:**

```sh
bin/bridgetown configure turbo
```

An optional script (`turbo_transitions.js`) is provided to add transition animation to Turbo navigation. If you don't wish to use any transition animations, you're welcome to delete the file. You can also edit the script to adjust the animation style or change the element being animated from `<main>` to whatever you prefer.

{%@ Note type: :warning do %}
It is recommended you add the `data-turbo-track="reload"` attribute to the `script` and CSS `link` tags in your HTML head. This will allow Turbo to perform a full page reload any time newly-deployed assets are available.
{% end %}

### Stimulus

⚙️ Sets up [Stimulus](https://stimulus.hotwired.dev) and adds an example controller.

🛠 **Configure using:**

```sh
bin/bridgetown configure stimulus
```

### TailwindCSS

🍃 Adds [TailwindCSS](https://tailwindcss.com) with an empty configuration along with [PurgeCSS](https://purgecss.com).

Please be aware that you need to have [PostCSS](https://postcss.org) installed to run this configuration.

This configuration will overwrite any existing `postcss.config.js` file.

🛠 **Configure using:**

```sh
bin/bridgetown configure tailwindcss
```

### PurgeCSS Post-Build Hook

🧼 Adds a builder plugin which runs [PurgeCSS](https://purgecss.com) against the output HTML + frontend JavaScript and produces a much smaller CSS output bundle for sites which use large CSS frameworks.

🛠 **Configure using:**

```sh
bin/bridgetown configure purgecss
```

### Bridgetown recommended PostCSS plugins

⛓️ Installs and configures a set of [PostCSS](https://postcss.org) plugins recommended by the Bridgetown community:

- [`postcss-easy-import`](https://github.com/trysound/postcss-easy-import)
- [`postcss-mixins`](https://github.com/postcss/postcss-mixins)
- [`postcss-color-function`](https://github.com/postcss/postcss-color-function)
- [`cssnano`](https://cssnano.co)

It will also configure [`postcss-preset-env`](http://preset-env.cssdb.org) to polyfill all features at [stage 2 and above](http://preset-env.cssdb.org/features#stage-2). If you don't need certain polyfills for your use case, you can bump up stage to 3 or 4 *(for example, [`custom properties`](http://preset-env.cssdb.org/features#custom-properties) won't get polyfilled if stage is set to 4)*. [`nesting-rules`](http://preset-env.cssdb.org/features#nesting-rules) and [`custom-media-queries`](http://preset-env.cssdb.org/features#custom-media-queries) are explicitly enabled.

This configuration will overwrite your `postcss.config.js` file.

🛠 **Configure using:**

```sh
bin/bridgetown configure bt-postcss
```
If you'd like to customize your setup further you can find more plugins [here](https://www.postcss.parts).

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
