---
title: Getting Started
order: 1
---

Bridgetown is a static site generator. You give it text written in your favorite markup language and it uses layouts to build a website and write it an output folder. You can tweak how you want the pages to look, what data gets displayed on the site, and more.

## Prerequisites

See [requirements]({{ '/docs/installation/#requirements' | relative_url }}).

## Instructions

1. Install a full [Ruby development environment]({{ '/docs/installation/' | relative_url }}).
2. Install Node and Yarn.
3. Install Bridgetown and [bundler]({{ '/docs/ruby-101/#bundler' | relative_url }}) [gems]({{ '/docs/ruby-101/#gems' | relative_url }}).
```
$ gem install bridgetown bundler
```
4. Create a new Bridgetown site at `./myblog`.
```
$ bridgetown new myblog
```
5. Change into your new directory.
```
$ cd myblog
```
6. Install frontend dependencies.
```
$ yarn install
```
7. Build the site and make it available on a local server.
```
$ yarn build && bundle exec bridgetown serve
```
8. Browse to [http://localhost:4000](http://localhost:4000){:target="_blank"}

If you encounter any errors during this process, see the
[troubleshooting]({{ '/docs/troubleshooting/#configuration-problems' | relative_url }}) page. Also,
make sure you've installed the development headers and other prerequisites as
mentioned on the [requirements]({{ '/docs/installation/#requirements' | relative_url }}) page.