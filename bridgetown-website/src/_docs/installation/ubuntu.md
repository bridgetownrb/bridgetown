---
title: Bridgetown on macOS
hide_in_toc: true
category: installation
ruby_version: 2.6.6
order: 0
---

## Install Ruby via rbenv

The version of Ruby available via Ubuntu's package manager is often out of date, so the best option is to install Ruby via [rbenv](https://github.com/rbenv/rbenv). People often use rbenv anyway to manage multiple Ruby versions, which comes in handy when you need to run a specific Ruby version on a project.

First, update your package list:

```sh
sudo apt update
```

Next, install the dependencies required to install Ruby:

```sh
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
```

Once the dependencies download, you can install rbenv itself. Clone the rbenv repository from GitHub into the directory `~/.rbenv`:

```sh
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

Next, add `~/.rbenv/bin` to your `$PATH` so that you can use the `rbenv` command line utility. Do this by altering your `~/.bashrc` file so that it affects future login sessions:

```sh
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```

Then add the command `eval "$(rbenv init -)"` to your `~/.bashrc` file so `rbenv` loads automatically:

```sh
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```

Next, apply the changes you made to your `~/.bashrc` file to your current shell session:

```s
source ~/.bashrc
```

Verify that rbenv is set up properly by using the `type` command, which will display more information about the `rbenv` command:

```sh
type rbenv
```

Your terminal window will display the following:

```sh
Output
rbenv is a function
…
```

Next, install the `ruby-build` plugin. This plugin adds the `rbenv install` command which simplifies the installation process for new versions of Ruby:

```sh
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Now you can install a new Ruby version. At the time of this writing, Ruby 2.6.6 is a fast and stable option. You'll also want to install Bundler to manage Rubygem dependencies.

```sh
rbenv install {{ page.ruby_version }}
rbenv global {{ page.ruby_version }}

ruby -v
> ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux]

gem install bundler -N
```

And that's it! Head over [rbenv command references](https://github.com/rbenv/rbenv#command-reference) to learn how to use different versions of Ruby in your projects.

{% render "docs/install/node_on_linux" %}
{% render "docs/install/bridgetown" %}
{% render "docs/install/concurrently" %}
