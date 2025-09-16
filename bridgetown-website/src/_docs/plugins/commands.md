---
title: Commands
order: 0
top_section: Configuration
category: plugins
---

Bridgetown plugins can provide commands for the `bridgetown` executable.

Commands are built using the [Thor](https://github.com/rails/thor) CLI toolkit, which also powers many popular Ruby libraries and frameworks.

To provide a comment, add a folder within your gem's `lib` folder with the path `bridgetown/features` and inside save a Ruby file with your exact gem name. Within that file, subclass `Thor` and use a registration block to notify Bridgetown how to include your command (example below).

You will also need to add a clause in your `.gemspec` to notify Bridgetown a command-line feature should be loaded:

```ruby
spec.metadata = {
  "bridgetown_features" => "true"
}
```

Commands are written in a `command [subcommand]` format, so if your base command is `river`, your logic will be contained within one or more subcommands:

```
bridgetown river # outputs a help message about the available subcommands
bridgetown river bank
bridgetown river flows
```

You can also use the `ConfigurationOverridable` concern to load the site configuration and optionally override keys with command line options passed to your command.

Here's an example of how to write a `Thor` subclass:

```ruby
# lib/bridgetown/features/my_example_plugin.rb

require_all "bridgetown-core/commands/concerns"

module MyPlugin
  module Commands
    class River < Thor
      include Bridgetown::Commands::ConfigurationOverridable

      Bridgetown::Commands::Registrations.register do
        desc "river <command>", "Take me to the river"
        subcommand "river", River
      end

      desc "bank", "Walk along the river bank"
      def bank
        puts "Out for a stroll..."
      end

      desc "flow", "Old man river, he just keeps on rolling along"
      option :destination, desc: "Override configuration file destination"
      def flow
        config = configuration_with_overrides(options)
        destination = config["destination"]

        puts "Flowing to your destination: #{destination}"
      end
    end
  end
end
```

In addition, if you want full access to [automations](/docs/automations) from within your command, you can include the Thor and custom Bridgetown actions:

```ruby
include Thor::Actions
include Bridgetown::Commands::Actions
```

Then your command can use Thor actions:

```ruby
say_status :river, "Go with the flow! :)"
```
