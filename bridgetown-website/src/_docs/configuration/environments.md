---
title: Environments
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

The "environment" of a Bridgetown site can affect the way certain processes work. Typically your site is run in the `development` environment. When running automated tests it will be run in the `test` environment, and upon deployment it should be run in the `production` environment.

When running CLI commands, you can specify the Bridgetown environment by
prepending it to your command:

```sh
BRIDGETOWN_ENV=production bin/bridgetown build
```

or by using the `-e` or `--environment` flag:

```sh
bin/bridgetown build -e production
bin/bridgetown console --environment=test
```

Alternatively, you can set the environment value using your computer or server
settings…most hosting companies allow environment variables to be specified via
a control panel of some kind. Or at the command line, look for a `.bashrc` or
`.zshrc` file in your home folder and add:

```sh
export BRIDGETOWN_ENV="production"
```

## Conditional Content

Suppose you set this conditional statement in your code:

{%@ Documentation::Multilang do %}
```erb
<% if Bridgetown.env.production? %>
  <%= render "analytics" %>
<% end %>
```
===
{% raw %}
```liquid
{% if bridgetown.environment == "production" %}
   {% render "analytics" %}
{% endif %}
```
{% endraw %}
{% end %}

When you build your Bridgetown site, the content inside the `if` statement won't be
rendered unless you also specify a `production` environment.

The default value for `BRIDGETOWN_ENV` is `development`. Thus if you omit
`BRIDGETOWN_ENV` from the build/serve commands, the default value will be
`BRIDGETOWN_ENV="development"`.

Some elements you might want to hide in development environments include comment forms or analytics. Conversely, you might want to expose an "Edit This Page" button in a development or staging environment but not include it in production environments.

## Defining Environments

The Legacy YAML format defines environments as key/value pairs, config/initializers.rb uses the environment as a condition for applying settings.

{%@ Documentation::Multilang do %}
```ruby
# config/initializers.rb

if Bridgetown.env.development?
  unpublished true
  future true
elsif Bridgetown.env.staging?
  unpublished true
end

```
===
{% raw %}
```yaml
# bridgetown.config.yml

development:
  unpublished: true
  future: true

staging:
  unpublished: true
```
{% endraw %}
{% end %}

The `development` environment will build documents that are marked as unpublished as
well as having a future date, the `staging` environment will only
build unpublished. And the `production` environment would exclude both sets.

## Environment Specific Metadata

In your `src/_data/site_metadata.yml`, you can add a block of YAML options
per environment. For example, given the following metadata:

```yaml
# src/_data/site_metadata.ymlTITLE

title: My Website

development:
  title: My (DEV) Website
```

Your site title would be "My Website" if built with a `production` environment,
and "My (DEV) Website" if built with a `development` environment. If you define your environments in the Legacy YAML config, you can also set per environment metadata values there. It is recommended to set metadata values in site_metadata.yml and Bridgetown values in initializers.

{%@ Note do %}
  #### Accessing the Environment in Your Ruby Code and Plugins

  Anywhere in Ruby code you write, you can check the current environment via `Bridgetown.environment` (`env` for short). You might decide to perform certain tests or verify data or perform some kind of operation in a `development` or `test` environment that you'd leave out in a `production` environment (or visa-versa).
{% end %}
