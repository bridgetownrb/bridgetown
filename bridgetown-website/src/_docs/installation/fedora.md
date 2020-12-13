---
title: Bridgetown on Fedora
hide_in_toc: true
category: installation
ruby_version: 2.6.6
order: 0
---

## Install Ruby

Fedora typically uses a recent version of Ruby that is maintained by the 
[Fedora Ruby special interest group](https://fedoraproject.org/wiki/SIGs/Ruby).

First, update your package list:

```sh
sudo dnf update
```

Then install Ruby as indicated [here](https://developer.fedoraproject.org/tech/languages/ruby/ruby-installation.html) using

```sh
sudo dnf install ruby
```

Verify that ruby is installed

```sh
ruby -v
> ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux]
```
Then install bundler as indicated [here](https://developer.fedoraproject.org/tech/languages/ruby/bundler-installation.html)

```sh
gem install bundler
```

And that's it! 

## Install Node & Yarn {#node}

Node is a Javascript runtime that can execute on a server or development machine. Yarn
is a package manager for Node packages. You'll need Node and Yarn in order to install
and use Webpack, the frontend asset compiler that runs alongside Bridgetown. Yarn is
also used along with Concurrently and Browsersync to spin up a live-reload development
server.

The easiest way to install Node and Yarn is via the package manager dnf.

```sh
sudo dnf update
sudo dnf install nodejs nodejs-devel
sudo dnf install nodejs-yarn
```

Then verify your installed versions:

```sh
node -v
> v12.19.0
yarn -v
> 1.21.1
```


{% render "docs/install/bridgetown" %}
{% render "docs/install/concurrently" %}
