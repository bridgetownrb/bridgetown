---
title: Choose Your Web Server
order: 250
top_section: Configuration
category: configuration
---

Bridgetown requires a [Rack-compliant](https://rack.github.io/rack) web server, ([along with Roda](/docs/routes)) for serving up statically-built files as well as any dynamic routes. The default server is [Falcon](https://socketry.github.io/falcon), but we also natively support [Puma](https://puma.io).

Select Puma when creating a new website using `-s` or `--server`:

```sh
bridgetown new -s puma
```

In development, Bridgetown will automatically detect the installed server and start it using its command line program. You can configure the options passed to the server's CLI in the `config/web_server.rb` file.

The most basic declaration in this file tells Bridgetown which server to use:

```ruby
server :falcon
```

Add options passed to the server by supplying a block:

```ruby
server :falcon do
  scheme        :https
  bind          { "#{scheme}://0.0.0.0" }
  rack_config   "config.ru"
  port          4000
  workers       1
  options       ["--cache"]
end
```

The values in `options` are passed to the CLI as-is, and all other parameters are parsed into the appropriate syntax before being passed to `falcon`.

An example using Puma:

```ruby
server :puma do
  config        "config/puma.rb"
  port          4000
  bind          "tcp://0.0.0.0"
  rack_config   "config.ru"
  options       ["-s"]
end
```

See the `Bridgetown::Rack::Environment::Falcon` and `Bridgetown::Rack::Environment::Puma` classes for all configuration options.

If you wish to use another Rack server which isn't natively supported in Bridgetown, you'll need to define the CLI command to run it.

```ruby
server :pitchfork do
  command ["pitchfork"]
end
```

The above example will execute `bundle exec pitchfork` to start your server. Any additional options will need to be defined manually within the same array supplied to `command`.

In production, use your server's command line program to start it directly. Bridgtown creates a configuration file for your chosen web server in the `config/` folder. Use this to customize your deployment and refer to your chosen server's documentation for further information.

* [Configuring Falcon for production](https://socketry.github.io/falcon/guides/deployment/index.html#configuration)
* [The Puma configuration file](https://puma.io/puma/Puma/DSL.html)
