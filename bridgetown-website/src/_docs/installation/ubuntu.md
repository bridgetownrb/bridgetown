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

gem install bundler
```

And that's it! Head over [rbenv command references](https://github.com/rbenv/rbenv#command-reference) to learn how to use different versions of Ruby in your projects.

## Install Node and Yarn

Node is a Javascript runtime that can execute on a server or development machine. Yarn is a package manager for Node packages. You'll need Node and Yarn in order to install and use Webpack, the frontend asset compiler that runs alongside Bridgetown.

```shell
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt-get install -y nodejs yarn
```

## Install Bridgetown

Now all that is left is to install Bridgetown!

```sh
gem install bridgetown
```

Now, try to create a new Bridgetown site at `./mysite`:

```sh
bridgetown new mysite
cd mysite
```

Install additional Bridgetown gems and frontend dependencies:

```sh
$ bundle install
$ yarn install
```

Now you should be able to build the site and make it available on a local server:

```sh
$ yarn build && bundle exec bridgetown serve
```

Try opening the site up in [http://localhost:4000](http://localhost:4000){:target="_blank"}. See something? Awesome, you're ready to roll! If not, try revisiting your installation and setup steps, and if all else fails, [reach out to the Bridgetown community for support](/docs/community/).
