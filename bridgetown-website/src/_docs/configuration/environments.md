---
title: Environments
hide_in_toc: true
order: 0
category: configuration
---

In the `build` (or `serve`) arguments, you can specify a Bridgetown environment
and value. The build will then apply this value in any conditional statements
in your content.

For example, suppose you set this conditional statement in your code:

{% raw %}
```liquid
{% if bridgetown.environment == "production" %}
   {% include disqus.html %}
{% endif %}
```
{% endraw %}

When you build your Bridgetown site, the content inside the `if` statement won't be
run unless you also specify a `production` environment in the build command,
like this:

```sh
BRIDGETOWN_ENV=production bridgetown build
```

Specifying an environment value allows you to make certain content available
only within specific environments.

The default value for `BRIDGETOWN_ENV` is `development`. Therefore if you omit
`BRIDGETOWN_ENV` from the build arguments, the default value will be
`BRIDGETOWN_ENV=development`. Any content inside
{% raw %}`{% if bridgetown.environment == "development" %}`{% endraw %} tags will
automatically appear in the build.

Your environment values can be anything you want (not just `development` or
`production`). Some elements you might want to hide in development
environments include Disqus comment forms or Google Analytics. Conversely,
you might want to expose an "Edit me in GitHub" button in a development
environment but not include it in production environments.

By specifying the option in the build command, you avoid having to change
values in your configuration files when moving from one environment to another.

{: .note}
To switch part of your config settings depending on the environment, use the
<a href="{{ '/docs/configuration/options/#build-command-options' | relative_url }}">build command option</a>,
for example <code>--config bridgetown.config.yml,_config_development.yml</code>. Settings
in later files override settings in earlier files.
