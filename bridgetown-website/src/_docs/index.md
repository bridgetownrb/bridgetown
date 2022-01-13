---
order: 10
title: Getting Started
top_section: Introduction
category: intro
---

Excited to get started? Woohoo! In case you're wondering, Bridgetown is a **progressive site generator**. You add content written in an author-friendly markup language like Markdown, alongside layouts and components using template syntax such as Liquid or ERB, and Bridgetown will then compile HTML, CSS, and JavaScript to an output website folder. You can tweak exactly how you want the pages to look, what data gets displayed on the site, and more. Bridgetown is powered by the Ruby programming language, as well as Node for JavaScript-based processing of your frontend assets. Bridgetown [started life as a Jekyll fork](/news/time-to-visit-bridgetown/) in early 2020, but it has since grown into so much more.

We'll explain much more about what Bridgetown is and what it can do for you in the sections ahead. Let's go!

## Quick Instructions {% if site.data.edge_version %}(EDGE RELEASE){% end %}

{% if site.data.edge_version %}
  {%@ Note type: "warning" do %}
    If you don't want to use the latest edge version of Bridgetown, [switch to the stable release documentation](https://www.bridgetownrb.com/docs/).
  {% end %}
{% end %}

{%@ Note do %}
  Upgrading from v0.x? [Read our 1.0 upgrade guide here.](/docs/installation/upgrade)
{% end %}

Read the [requirements](/docs/installation) for more information on what you'll need to have set up in advance, primarily **Ruby** and **Node**/**Yarn**. Then:

1. Install **Bridgetown** and related gems:
{%- if site.data.edge_version -%}
```
$ gem install bridgetown -N -v {{ Bridgetown::VERSION }}
```
{%- else -%}
```
$ gem install bridgetown -N
```
{%- end -%}

2. Create a new Bridgetown site at `./mysite`.
```
$ bridgetown new mysite
```

3. Change into your new directory.
```
$ cd mysite
```

4. Build the site and run a live-reload development server:
```
$ bin/bridgetown start
```

5. Browse to [http://localhost:4000](http://localhost:4000){:target="_blank"}

6. And you're done! (That's the goal at least 😊)

{%@ Note do %}
Detailed installation instructions for macOS, Ubuntu Linux, Fedora Linux and Windows 10 are [available here](/docs/installation).
{% end %}

{%@ Note do %}
Prefer ERB or Serbea over Liquid? Prefer Webpack over esbuild? Prefer Sass over vanilla CSS? [Read about the available `new` options here](/docs/command-line-usage).
{% end %}

{%@ Note type: :warning do %}
Still stuck? [Please reach out to the Bridgetown community for support](/community). What might take you three hours to eventually figure out could take a mere 10 minutes with the right pointers!
{% end %}

Bridgetown comes with the `bridgetown` CLI tool as well as a few Rake tasks and Yarn scripts,
so be sure to read up on the [command line usage documentation](/docs/command-line-usage).

## More About the Tech Specs

Bridgetown is sometimes called a "static site generator" or a "Jamstack" web framework. We think it's simpler to think in terms of _progressive generation_ — the idea that the moment at which your over-the-wire HTML & JSON is generated can vary, depending on the method you choose to use on a route-by-route basis as well as the architecture of your frontend. Bridgetown starts off in SSG (Static Site Generation) mode, and you can opt-into SSR (Server-Side Rendering) mode only if and when you need it. And depending on your choice of frontend tooling, you can leverage CSR (Client-Side Rendering) along with hydration techniques to add highly dynamic and interactive experiences—without compromising on base site speed and efficiency.

Bridgetown works best as part of a version-controlled repository powered by Git. You'll likely want to store your repository on a service like [GitHub](https://github.com) so that you and everyone else working on the website (plus your hosting provider) all have direct, secure access to the latest website content and design files.

During the development process, you'll run Bridgetown from the command line on your local development machine (or perhaps a remote staging server). Once content is ready to publish, you'll want to commit your website codebase to the Git repository and use an automated build tool to generate and upload the final output to a server or CDN (Content Delivery Network). [Render](https://www.render.com) is a popular service for this, but there are many others. You can also just literally copy the generated files contained in the `output` folder to any HTTP web server and it should Just Work. 😊

For more details on how the Bridgetown build process works and what goes into creating a site, continue on to read our **Core Concepts** guide.
