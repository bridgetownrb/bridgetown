---
title: Environments
hide_in_toc: true
order: 0
category: configuration
---

When running the `build` or `serve` commands, you can specify a Bridgetown
environment variable: `BRIDGETOWN_ENV`. The build will then apply this value in
any conditional statements in your content. You specify the environment by
prepending it to your command:

```sh
BRIDGETOWN_ENV=production bridgetown build
```

Alternatively, you can set the environment value using your computer or server
settings…most hosting companies allow environment variables to be specified via
a control panel of some kind. Or at the command line, look for a `.bashrc` or
`.zshrc` file in your home folder and add:

```sh
export BRIDGETOWN_ENV="production"
```

For example, suppose you set this conditional statement in your code:

{% raw %}
```liquid
{% if bridgetown.environment == "production" %}
   {% render "analytics" %}
{% endif %}
```
{% endraw %}

When you build your Bridgetown site, the content inside the `if` statement won't be
rendered unless you also specify a `production` environment.

{% rendercontent "docs/note" %}
  If you you're using ERB or another Ruby template language, you can write `Bridgetown.env.development?`, `Bridgetown.env.production?`, and so forth. Refer to the [ERB and Beyond](/docs/erb-and-beyond) docs for further details.
{% endrendercontent %}

The default value for `BRIDGETOWN_ENV` is `development`. Thus if you omit
`BRIDGETOWN_ENV` from the build/serve commands, the default value will be
`BRIDGETOWN_ENV="development"`. Any content inside
{% raw %}`{% if bridgetown.environment == "development" %}`{% endraw %} tags will
automatically appear in the build.

Your environment values can be anything you want (not just `development` or `production`). Some elements you might want to hide in development environments include comment forms or analytics. Conversely, you might want to expose an "Edit me in GitHub" button in a development environment but not include it in production environments.

## Environment-specific Configurations

In your `bridgetown.config.yml` config file, as well as the
`src/_data/site_metadata.yml` metadata file, you can add a block of YAML options
per environment. For example, given the following metadata:

```yaml
# src/_data/site_metadata.yml

title: My Website

development:
  title: My (DEV) Website
```

Your site title would be "My Website" if built with a `production` environment,
and "My (DEV) Website" if built with a `development` environment. You can specify any
number of environment blocks that you wish. For example:

```yaml
# bridgetown.config.yml

development:
  unpublished: true
  future: true

staging:
  unpublished: true
```

The `development` environment will build documents that are marked as unpublished as
well as having a future date, whereas the `staging` environment will only
build unpublished. And the `production` environment would exclude both sets.

{% rendercontent "docs/note", title: "Top Tip: Accessing the Environment in Your Ruby Code and Plugins", extra_margin: true %}
  Anywhere in Ruby code you write, you can check the current environment via `Bridgetown.environment`. You might decide to perform certain tests or verify data or perform some kind of operation in a `development` or `test` environment that you'd leave out in a `production` environment (or visa-versa).
{% endrendercontent %}
