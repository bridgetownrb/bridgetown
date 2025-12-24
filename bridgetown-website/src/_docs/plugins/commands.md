---
title: Commands
order: 0
top_section: Configuration
category: plugins
---

Bridgetown sites and plugins can provide commands for the `bridgetown` executable. Commands are built using the [Samovar](https://github.com/ioquatix/samovar) CLI toolkit.

To provide a command from within your site repo, create a `config/custom_commands.rb` and define one or more `Bridgetown::Command` subclasses as described below.

To provide a command using a gem, add a folder within your gem's `lib` folder with the path `bridgetown/features` and inside save a Ruby file with your exact gem name. Within that file, subclass `Bridgetown::Command` and notify Bridgetown how to include your command as described below.

You will also need to add a clause in your `.gemspec` to notify Bridgetown a command-line feature should be loaded:

```ruby
spec.metadata = {
  "bridgetown_features" => "true"
}
```

## Command Structure

Commands can be written "standalone" or they can written in a `command [subcommand]` format. In the latter case, given a base command of `river`, your logic will be contained within one or more subcommands:

```
bridgetown river # outputs a help message about the available subcommands
bridgetown river bank
bridgetown river flows
```

You can also use the `ConfigurationOverridable` concern to load the site configuration and optionally override keys with command line options passed to your command.

The simplest possible form of a command is as follows:

```ruby
module Bridgetown
  module Commands
    class Howdy < Bridgetown::Command
      self.description = "Give a hearty howdy"

      def call
        puts "Well howdy there!"
      end
    end

    register_command :howdy, Howdy
  end
end
```

The body of your command code goes in the `call` method, and once your class is defined you call the `register_command` method within `Bridgetown::Commands` to include it in the CLI.

Here's an example of how to write a command with multiple subcommands. Each subcommand is its own nested class, and you wire them together using Samovar's `nested` method:

```ruby
# lib/my_example_plugin/features/my_example_plugin.rb

module Bridgetown
  module Commands
    class River < Bridgetown::Command
      self.description = "Take me to the river"

      class Bank < Bridgetown::Command
        self.description = "Walk along the river bank"

        options do
          option "-w/--where <TO>", "Where to?", required: true
        end

        def call
          puts "Out for a stroll...to #{options[:where]}?"
        end
      end

      class Flow < Bridgetown::Command
        include Bridgetown::Commands::Automations
        include Bridgetown::Commands::ConfigurationOverridable

        self.description = "Old man river, he just keeps on rolling along"

        options do
          option "--destination <DEST>", "Override configuration file destination"
        end

        def call
          config = configuration_with_overrides(options)
          destination = config.destination

          say_status :river, "Flowing to your destination: #{destination}"
        end
      end

      nested :command, {
        "bank" => Bank,
        "flow" => Flow,
      }, required: true

      def call = @command.call
    end

    register_command :river, River
  end
end
```

If you want full access to [automations](/docs/automations) from within your command, you can include the Freyia & Bridgetown automation tasks:

```ruby
include Bridgetown::Commands::Automations
```

Then your command can run those automations:

```ruby
say_status :river, "Go with the flow! :)"
```
