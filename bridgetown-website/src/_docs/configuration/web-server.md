---
title: Web Server Configuration
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

Bridgetown requires a [Rack-compliant](https://rack.github.io/rack) web server, ([along with Roda](/docs/routes)) for serving up statically-built files as well as any dynamic routes. The default server is [Falcon](https://socketry.github.io/falcon), but we also natively support [Puma](https://puma.io).

In development (`bin/bridgetown start`), Bridgetown uses [Rackup](https://github.com/rackup) to start the web server. Since this is a generic interface, the configuration options are limited. By default, Bridgetown serves over HTTP via port `4000`, bound to `0.0.0.0` (this makes it accessible via localhost as well as the network).

You can change the port using `-P`:

```shell
$ bin/bridgetown start -P 6000
```

And, to change the IP address to something other than `0.0.0.0`, provide a `--bind` / `-B` argument:

```shell
$ bin/bridgetown start -B 192.168.1.1
```

In production, use your server's command line program to start it directly. Bridgtown creates a configuration file for your chosen web server in the `config/` folder. Use this to customize your deployment and refer to your chosen server's documentation for further information.

* [Configuring Falcon for production](https://socketry.github.io/falcon/guides/deployment/index.html#configuration)
* [The Puma configuration file](https://puma.io/puma/Puma/DSL.html)
