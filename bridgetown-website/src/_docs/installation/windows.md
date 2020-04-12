---
title: Bridgetown on Windows
hide_in_toc: true
category: installation
order: 0
---

{% include help_needed.md %}

The easiest way to use Bridgetown on Windows is to install the _Windows Subsystem for Linux_. This provides a Linux development environment in which you can install Bash, Ruby, and other tools necessary to run Bridgetown in an optimized fashion.

Try reading [these excellent instructions by GoRails](https://gorails.com/setup/windows/10) to install Ubuntu Linux on Windows, and then once you're reached the "Installing Rails" portion, you can continue as follows:

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
