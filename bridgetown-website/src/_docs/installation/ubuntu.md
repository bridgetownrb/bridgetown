---
title: Bridgetown on Ubuntu
top_section: Setup
category: installation-guides
back_to: installation
ruby_version: 3.0.2
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
sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
```

(If on an older Ubuntu version, `libgdbm6` won't be available. Try installing `libgdbm5` instead.)

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
rbenv is a function
…
```

Next, install the `ruby-build` plugin. This plugin adds the `rbenv install` command which simplifies the installation process for new versions of Ruby:

```sh
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Now you can install a new Ruby version. At the time of this writing, Ruby {{ resource.data.ruby_version }} is the latest stable version. (Note: the installation may take a few minutes to complete.)

```sh
rbenv install {{ resource.data.ruby_version }}
rbenv global {{ resource.data.ruby_version }}

ruby -v
> ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [aarch64-linux]
```

(If for some reason `bundler` isn't installed automatically, just run `gem install bundler -N`)

And that's it! Check out [rbenv command references](https://github.com/rbenv/rbenv#command-reference) to learn how to use different versions of Ruby in your projects.

{%@ "docs/install/node_on_linux" %}
{%@ "docs/install/bridgetown" %}
