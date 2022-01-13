---
order: 40
title: Installation Guides
description: Official guides to install Bridgetown on macOS, GNU/Linux or Windows.
top_section: Setup
category: installation-guides
---

Bridgetown is software written in Ruby, a friendly programming language that maximizes programmer happiness and makes it easy to build and customize open source projects. You will need to install Bridgetown as a Gem after you set up your Ruby language environment. You will also need to install Node and Yarn to manage your website's frontend assets.

{%@ Note do %}
For a quick summary of how to install Bridgetown, read [Getting Started](/docs/). What follows are more in-depth guides to setting up your developer or server environments.
{% end %}

## Requirements

If you don't have some or all of these tools, our setup guides for macOS,
Ubuntu Linux, and Ubuntu for Windows will help you install them.

* [GCC](https://gcc.gnu.org/install/) and [Make](https://www.gnu.org/software/make/)
  (which you can check by running `gcc -v`,`g++ -v`  and `make -v`).

* [Ruby](https://www.ruby-lang.org/en/downloads/) version
  **{{ site.data.requirements.min_ruby }}** or above (ruby version can be checked by
  running `ruby -v`)

* [Node](https://nodejs.org) version **{{ site.data.requirements.min_node }}** or
  above (which you can check by running `node -v`)

* [Yarn](https://yarnpkg.com) (which you can check by running `yarn -v`)

## Guides

For detailed installation instructions, take a look at the guide for your operating
system:

* [macOS](/docs/installation/macos)
* [Fedora Linux](/docs/installation/fedora)
* [Ubuntu Linux](/docs/installation/ubuntu)
* [Windows (via Linux Subsystem + Ubuntu)](/docs/installation/windows)

## Upgrading?

We now have an [official upgrade guide](/docs/installation/upgrade) for migrating your Bridgetown v0.2x website to v1.0.
