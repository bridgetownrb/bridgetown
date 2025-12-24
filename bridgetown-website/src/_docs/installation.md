---
order: 40
title: Installation Guides
description: Official guides to install Bridgetown on macOS, GNU/Linux or Windows.
top_section: Setup
category: installation-guides
---

Bridgetown is software written in Ruby, a friendly programming language that maximizes programmer happiness and makes it easy to build and customize open source projects. You will need to install Bridgetown as a Gem after you set up your Ruby language environment. You will also need to install Node to manage your website's frontend assets.

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

## Guides

For detailed installation instructions, take a look at the guide for your operating
system:

* [macOS](/docs/installation/macos)
* [Fedora Linux](/docs/installation/fedora)
* [Ubuntu Linux](/docs/installation/ubuntu)
* [Windows (via Linux Subsystem + Ubuntu)](/docs/installation/windows)

## Gem Servers

By default, Bundler will install gems from the RubyGems service. You can configure your Bridgetown project post-install to bundle via the alternative community gem server [gem.coop](https://gem.coop) by modifying the `source` at the top of your project's `Gemfile`:

```ruby
source "https://gem.coop"
```

In addition, you also have the option of loading first-party Bridgetown gems directly from our own canonical gem server, [gems.bridgetownrb.com](https://gems.bridgetownrb.com). For example:

```ruby
source "https://gems.bridgetownrb.com" do
  gem "bridgetown"
  gem "bridgetown-feed"
end
```

The list of available gems is provided at the link.

## Upgrading?

We now have an [official upgrade guide](/docs/installation/upgrade) for migrating your Bridgetown website to v2.x.
