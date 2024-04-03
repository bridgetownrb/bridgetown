---
order: 60
title: Command Line Usage
top_section: Setup
category: command-line-usage
---

The Bridgetown gem makes the `bridgetown` executable available to you in your terminal. In a site project, a binstub is provided in the `bin` folder so you can execute `bin/bridgetown` and ensure you're using the correct version of Bridgetown as specified in your `Gemfile`. (The shorter `bin/bt` alias is also provided.)

You can run `bin/bridgetown` to see a list of available commands as well as Rake tasks which either come with Bridgetown or are located in your `Rakefile`. See below for information on how to define your own Rake tasks.

The `help <command>` command provides more information about the available options for any specific command.

Available commands are:

{% raw %}
* `bridgetown new PATH` - Creates a new Bridgetown site at the specified path with a default configuration and typical site folder structure.
  * Use the `--apply=` or `-a` option to [apply an automation](/docs/automations) to the new site.
  * Use the `--configure=` or `-c` option to [apply one or more bundled configurations](/docs/bundled-configurations) to the new site.
  * Use the `-t` option to choose ERB or Serbea templates instead of Liquid (aka `-t erb`).
  * Use the `--use-sass` option to configure your project to support Sass.
* `bin/bridgetown start` or `s` - Boots the Rack-based server (using Puma) at `localhost:4000`. In development, you'll get live reload functionality as long as `{% live_reload_dev_js %}` or `<%= live_reload_dev_js %>` is in your HTML head.
* `bin/bridgetown deploy` - Ensures that all frontend assets get built alongside the published Bridgetown output. This is the command you'll want to use for [deployment](/docs/deployment).
* `bin/bridgetown build` or `b` - Performs a single build of your site to the `output` folder. Add the `-w` flag to also regenerate the site whenever a source file changes.
* `bin/bridgetown console` or `c` - Opens up an IRB console and lets you inspect your site configuration and content "under the hood" using Bridgetown's native Ruby API. See below for information on how to add your own console methods.
  * The console command loads up the `console` [configuration context](/docs/configuration/initializers/#using-only-except-and-understanding-initialization-contexts) by default. Use the `--server-config` option (or `-s`) to load the server context instead (which also requires Puma and instantiates the Roda server application) for troubleshooting. In the future we hope to provide Rack Test `get`/`post`/etc. methods so you can try out responses right in the console.
* [`bin/bridgetown plugins [list|cd]`](/docs/commands/plugins) - Display information about installed plugins or allow you to copy content out of gem-based plugins into your site folders.
* `bin/bridgetown apply` - Run an [automation script](/docs/automations) for your existing site.
* `bin/bridgetown configure CONFIGURATION` - Run a [bundled configuration](/docs/bundled-configurations) for your existing site. Invoke without arguments to see all available configurations.
* `bin/bridgetown date` - Displays the current date and time so you can copy'n'paste it into your front matter.
* `bin/bridgetown help` - Shows help, optionally for a given subcommand, e.g. `bridgetown help build`.
* `bin/bridgetown doctor` - Outputs any deprecation or configuration issues.
* `bin/bridgetown clean` - Removes all generated files: destination folder, metadata file, and Bridgetown caches.
* `bin/bridgetown esbuild ACTION` - Allows you to perform actions such as `update` on your project's esbuild configuration. Invoke without arguments to see all available actions.
{% endraw %}

To change Bridgetown's default build behavior have a look through the [configuration options](/docs/configuration). You'll also want to read up on [how to set your Bridgetown environment](/docs/configuration/environments) for different use cases.

For deployment, if you need to add an extra step to copy `output` to a web server or run some script post-build, putting that in the `deploy` task in your `Rakefile` is a good way to go.

Also take a look at the `scripts` configuration in `package.json` which provides integration points with the frontend bundler.

## Rakefile and Rake tasks

Rake is a task runner for Ruby applications. Tasks can execute shell commands, run through Ruby logic, or perform automation actions. Some tasks can be written to depend on the execution of prerequisite tasks.

In the default `Rakefile` which comes with a new Bridgetown site project, you'll see a few tasks defined which are used by various built-in commands. For example, when you run the `bin/bridgetown start` command in a typical development environment, one of the tasks it performs is `frontend:dev`. You can see that in your Rakefile here:

```ruby
namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "yarn run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "yarn run esbuild-dev"
  rescue Interrupt
  end
end
```

You're welcome to modify the tasks in your Rakefile as needed. For example, for this website we run a linter which looks for unnecessary `<div>` and `<span>` tags in the output HTML. This check is run for each deployment, so the `deploy` task has been modified to include this step:

```ruby
desc "Build the Bridgetown site for deployment"
task deploy: [
  :clean,
  :linthtml, # this has been added to the default deploy task
  "frontend:build",
] do
  Bridgetown::Commands::Build.start
end

task :linthtml do # this is custom for the website project
  sh "yarn lint:html"
end
```

As is shown in comments for the default Rakefile, you can add your own [automations](/docs/automations) directly inside of Rake tasks. In the provided example, you can see that a `site` object is available, and within an `automation` block you can call Thor actions just like in standard automation scripts:

```ruby
task :my_task => :environment do
  puts site.root_dir
  automation do
    say_status :rake, "I'm a Rake tast =) #{site.config.url}"
  end
end
```

Running `bin/bridgetown my_task` would result in printing out the root path of the site as well as executing the `say_status` Thor action.

{%@ Note type: :warning do %}
  The `site` variable is lazy-loaded, aka the site doesn't initialize before the `site` variable is accessed. You can add `run_initializers` to the top of your task block to ensure all site configurations, hooks, etc. have been executed. You can also pass a different initializer context (other than `:rake`) by providing the context as an argument. For example: `run_initializers context: :server`
{% end %}

## Console Commands

When you run `bin/bridgetown console` or `c`, you have access to an instantiated `site` object which you can use to investigate its content and configuration. You can also call `collections` directly as a shorthand for `site.collections`, and you can run `reload!` anytime you want to reset/reload site content and plugins.

Besides those built-in console methods, you can add your own! Just define your own `ConsoleMethods` module and include that in Bridgetown's standard module.

```ruby
module ConsoleMethods
  def ruby_rocks
    "MINASWAN!"
  end
end

Bridgetown::ConsoleMethods.include ConsoleMethods
```

Typing in `ruby_rocks` and pressing Enter in the console would result in the output: `MINASWAN!`. (In case you're wondering, [MINASWAN](https://en.wiktionary.org/wiki/MINASWAN) is a fun saying within the Ruby community which stands for Matz Is Nice And So We Are Nice. 😄)

To see a list of all console methods available, type `Bridgetown::ConsoleMethods.instance_methods`.
