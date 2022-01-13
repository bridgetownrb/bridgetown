---
order: 230
title: Automations
top_section: Configuration
category: automations
---

You can write automation scripts which act on new or existing sites to perform
tasks such as adding gems, updating configuration, inserting code, copying
files, and much more.

Automations are similar in concept to Gatsby Recipies or Rails App Templates.
They're uniquely powerful when combined with [plugins](/docs/plugins), as an
automation can install and configure one or more plugins from a single script.

You could also write an automation to run multiple additional automations, and
apply that to a brand-new site to set everything up just how you want it in a
repeatable and automatic fashion.

Automations can be loaded from a local path, or they can be loaded from remote
URLs including GitHub repositories and gists. You can also run automation scripts [from within Rake tasks](/docs/command-line-usage#rakefile-and-rake-tasks).

## Running Automations

For a new site, you can apply an automation as part of the creation process
using `--apply=` or `-a`:

```sh
bridgetown new mysite --apply=/path/to/automation.rb
```

For existing sites, you can use the `apply` command:

```sh
bin/bridgetown apply /path/to/automation.rb
```

If you don't supply any filename or URL to `apply`, it will look for
`bridgetown.automation.rb` in the current working directory

```sh
vim bridgetown.automation.rb # save an automation script

bin/bridgetown apply
```

Remote URLs to automation scripts are also supported, and GitHub repo or gist
URLs are automatically transformed to locate the right file from GitHub's CDN:

```sh
# Install and configure the bridgetown-cloudinary gem
bin/bridgetown apply https://github.com/bridgetownrb/bridgetown-cloudinary
```

You can also load a file other than `bridgetown.automation.rb` from GitHub:

```sh
# Set up a default configuration for Netlify hosting
bin/bridgetown apply https://github.com/bridgetownrb/automations/netlify.rb
```

## Writing Automations

An automation script is nothing more than a Ruby code file run in the context
of an instance of `Bridgetown::Commands::Apply`. Available to you are [all the
actions provided by Thor](https://github.com/erikhuda/thor/wiki/Actions), such
as `run` to run a CLI executable, or `ask` to prompt the user for details, or
`say_status` to provide helpful messages in the terminal.

Here's an example of a simple automation which creates a new file in a
site repo:

```ruby
create_file "netlify.toml" do
  <<~NETLIFY
    [build]
      command = "bin/bridgetown deploy"
      publish = "output"
    [build.environment]
      NODE_VERSION = "12"
    [context.production.environment]
      BRIDGETOWN_ENV = "production"
  NETLIFY
end
```

Bridgetown also provides actions which are useful for working in the context
of website projects.

Here's an example of a plugin's `bridgetown.automation.rb` which adds itself
as a gem to a site and updates configuration based on user input:

```ruby
say_status "Cloudinary", "Installing the bridgetown-cloudinary plugin..."

cloud_name = ask("What's your Cloudinary cloud name?")

add_bridgetown_plugin "bridgetown-cloudinary"

append_to_file "bridgetown.config.yml" do
  <<~YAML

    cloudinary:
      cloud_name: #{cloud_name}
  YAML
end
```

There is a whole variety of possible actions at your disposal:

```ruby
add_bridgetown_plugin("my-plugin") # bundle add…
add_yarn_for_gem("my-plugin") # yarn add… (looks up yarn metadata in plugin gemspec)

# add another gem, but still continue if there's a Bundler error
run 'bundle add some-other-gem --version ">= 4.1.0, < 4.3.0"', abort_on_failure: false

create_builder "my_nifty_builder.rb" do # adds file in plugins/builders
  <<~RUBY
    class MyNeatBuilder < SiteBuilder
      def build
        puts MyPlugin.hello
      end
    end
  RUBY
end

javascript_import do # updates frontend/javascript/index.js
  <<~JS
    import { MyPlugin } from "my-plugin"

    const myPlugin = MyPlugin.setup({
      // configuration options
    })
  JS
end

create_file "src/_data/plugin_data.yml" do
  <<~YAML
    data:
      goes:
        here
  YAML
end

color = ask("What's your favorite color?")

append_to_file "bridgetown.config.yml" do
  <<~YAML

    my_plugin:
      favorite_color: #{color}
  YAML
end
```

In summary, automations are a fantastic method of saving repeatable setup
steps for you to reuse later in new projects, or you can share scripts with
the world at large. Use them for plugins, themes, or just quick one-off
scripts.
