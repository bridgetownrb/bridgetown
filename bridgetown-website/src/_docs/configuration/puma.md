---
title: Puma Configuration
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

Bridgetown uses the Puma web server ([along with Roda](/docs/routes)) for serving up statically-built files as well as any dynamic routes.

The default port number for the server is `4000`. The easiest way to change this is to add this to your config YAML:

```yaml
bind: "tcp://0.0.0.0:4001"

# or if you only want to change this in development:
development:
  bind: "tcp://0.0.0.0:4002"
```

Alternatively, you can set the `BRIDGETOWN_PORT` environment variable which will be picked up by Puma. Or you can pass an entire bind URL via `-B` or `--bind` on the command line:

```sh
bin/bridgetown start --bind=tcp://0.0.0.0:3000
```

Other Puma configuration options are available in the `config/puma.rb` file in your Bridgetown repo. Many of these Ruby <abbr title="Domain-Specific Language">DSL</abbr> options, such as concurrency (how many separate forked Puma processes startup) and per-process threading, are [documented here](https://puma.io/puma/Puma/DSL.html).
