---
order: 6.75
next_page_order: 7
title: Bundled Configurations
top_section: Configuration
category: bundledconfigurations
---

**_This feature hasn't been released yet and is available in the `main` branch._**


Bridgetown bundles a number of automation scripts to set up common project
configurations. You can run these scripts using `bundle exec bridgetown
configure [CONFIGURATION]`

The configurations we include are:
- [TailwindCSS](#tailwindcss) (`tailwindcss`)
- [PurgeCSS Post-Build Hook](#purgecss-post-build-hook) (`purgecss`)
- [Netlify TOML Configuration](#netlify-toml-configuration) (`netlify`)
- [Swup.js Page Transitions](#swupjs-page-transitions) (`swup`)
- [Automated Test Suite using Minitest](#automated-test-suite-using-minitest) (`minitesting`)

The full list of configurations can also be seen by running `bridgetown configure` without arguments.

Bundled configurations can also be run while creating a new Bridgetown project using the `--configure=` or `-c` flag and passing in a comma-separated list of configurations.

```
bundle exec bridgetown new my_project -c swup,purgecss
```

## A bit about the configurations

### TailwindCSS

🍃 Adds [TailwindCSS](https://tailwindcss.com) with an empty configuration along with [PurgeCSS](https://purgecss.com).

Please be aware that you need to have [PostCSS](https://postcss.org) setup to run this configuration. You can create a new Bridgetown project with PostCSS using `bridgtown new my_project --use-postcss`.

This configuration will overwrite your `postcss.config.js` file.

🛠 **Configure using:**

```
bundle exec bridgetown configure tailwindcss
````

### PurgeCSS Post-Build Hook

🧼 Adds a builder plugin which runs [PurgeCSS](https://purgecss.com) against the output HTML + frontend Javascript and produces a much smaller CSS output bundle for sites which use large CSS frameworks.

🛠 **Configure using:**

```
bundle exec bridgetown configure purgecss
```

### Netlify TOML Configuration

⚙️ Adds a basic configuration to your site for use in [Netlify](https://netlify.com) deployments.

🛠 **Configure using:**

```
bundle exec bridgetown configure netlify
```

### Swup.js Page Transitions

⚡️ Adds [Swup](https://swup.js.org) for fast animated page transitions that make your site feel modern and cool. (If you've used Turbolinks or Hotwire, you'll love Swup!)

🛠 **Configure using:**

```
bundle exec bridgetown configure swup
```


### Automated Test Suite using Minitest

⚙️ Adds a basic test suite using [Minitest](https://rubygems.org/gems/minitest) and Rails DOM assertions for extremely fast verification of your output HTML.

🛠 **Configure using:**

```
bundle exec bridgetown configure minitesting
```