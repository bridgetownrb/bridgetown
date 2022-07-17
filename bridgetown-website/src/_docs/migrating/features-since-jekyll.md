---
title: Bridgetown Features Post-Jekyll
top_section: Introduction
category: migrating
back_to: migrating-from
order: 0
---

Here's a rundown of some **40 features** Bridgetown has implemented since the fork from Jekyll in early 2020:

* All-new "resource" content engine built from the ground up to facilitate demanding content needs.
* Pages, posts, and custom collection items all share a common interface and behave in a predicable manner.
* Fully custom taxonomies and defined relations (belongs to, has many, etc.) between resources.
* Content model objects with load/save abilities which underlie resources.
* The resource extension API.
* Ruby front matter in addition to YAML.
* Inspectors for Nokogiri-based modification of HTML & XML resources.
* Configurable auto-sorted collections.
* Robust I18n support for multilingual deployments.
* An object-oriented componentized view layer.
* Support for ERB & other Ruby template engines.
* Ruby-based automation scripts & Rake tasks.
* A console command for interacting and testing with your site via IRB.
* Customizable console methods.
* Fast, integrated frontend building via esbuild (or Webpack).
* PostCSS support by default (Dart Sass support also available).
* A Rack & Puma-based web server to supersede WEBrick.
* A next-gen plugin API via Builders.
* Plugin source manifests & frontend integration with Yarn auto-install.
* A clearer, modern  file & folder structure.
* A powerful external API DSL for generating new content.
* Support for pagination and prototype (aka archive) pages available out of the box.
* YAML file-based front matter defaults with folder cascades.
* Rapid installation of Hotwire (Turbo, Stimulus).
* Bundled configurations for popular libraries & tools such as Lit, Shoelace, and Open Props.
* Easy website testing setup w/Minitest or Cypress.
* Auto-reloadable local plugins via Zeitwerk.
* Thor-based CLI tools with straightfoward extensibility.
* `<mark>` highlighter support in Markdown content via `::` or `==`.
* SSR via an integration with Roda, a blazing-fast Ruby web toolkit.
* File-based dynamic routes.
* Environment-specific metadata.
* Streamlined installation processes on modern Unix-style OSes with modern Ruby versions.
* YARD API documentation (still a work in progress but getting there!).
* ViewComponent compatibility shim.
* Modern Liquid (v5+) support.
* SSG/SSR & client-side hydration of Lit-based web components.
* Many Ruby enhancements included via ActiveSupport.
* A large number of "breaking" fixes Jekyll had left unaddressed.
* Active first-party support via community Discord & GitHub Discussions + commercial support.

**Ready to migrate to Bridgetown?** [Here's an overview guide of the steps you'll want to take.](/docs/migrating/jekyll)