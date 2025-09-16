---
title: Puma Configuration
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

Bridgetown uses the Puma web server ([along with Roda](/docs/routes)) for serving up statically-built files as well as any dynamic routes.

The most common change you might make to your Puma configuration is the port number. By default, Bridgetown serves over HTTP via port `4000`, bound to `0.0.0.0` (this makes it accessible via localhost as well as the network). This is true in production as well as local development. In order of preference, here's how you can change that:

* **CLI:** `--port=NN` / `-P NN` this will override Puma's port number, even when an environment variable may be set.
* **Environment:** if the `BRIDGETOWN_PORT` environment variable is set (possibly through using [Dotenv](https://edge.bridgetownrb.com/docs/configuration/initializers#dotenv)), this will be used.
* **YAML Config:** while generally-speaking Bridgetown configurations are now provided via Ruby, you can use `bridgetown.config.yml` to set the `port` value. Unfortunately due to a timing issue, the port number cannot be overwritten using a Ruby initializer.

To change the IP address to something other than `0.0.0.0`, you can provide a `--bind` / `-B` command line argument.

Other Puma configuration options are available in the `config/puma.rb` file in your Bridgetown repo. Many of these Ruby <abbr title="Domain-Specific Language">DSL</abbr> options, such as concurrency (how many separate forked Puma processes startup) and per-process threading, are [documented here](https://puma.io/puma/Puma/DSL.html).
