---
order: 1
title: Getting Started
top_section: Introduction
category: intro
---

In a nutshell, Bridgetown is a **static site generator**. You give it text written in an author-friendly markup language like Markdown, and it uses layouts and templates to build a website and save the compiled HTML, CSS, and JavaScript to an output folder. You can tweak how you want the pages to look, what data gets displayed on the site, and more.

Bridgetown works best as part of a version-controlled repository powered by Git. You can centrally store your repository on a service like [GitHub](https://github.com) so that you and everyone else working on the website (plus your hosting provider) all have direct, secure access to the latest website content and design files.

During the development process, you will likely be running Bridgetown from the command line on your local developer machine (or perhaps a remote staging server). Once content is ready to publish, you would commit your website codebase to the Git repository and use an automated build tool to generate and upload the final output to a server or CDN (Content Delivery Network). [Render](https://www.render.com) is a popular service for this, but there are many others. You can also just literally copy the generated files contained in the `output` folder to any HTTP web server and it should Just Work. 😊

For more background on this development approach, [read up on our Jamstack primer](/docs/jamstack/).

For a succinct overview of how the Bridgetown build process works and what goes into creating a site, [read our Core Concepts guide](/docs/core-concepts/).

## Quick Instructions {% if bridgetown.version contains "beta" %}(BETA RELEASE){% endif %}

Read [requirements]({{ '/docs/installation' | relative_url }}) for more information on what you'll need to have set up in advance.

The basic installation process is as follows:

1. Install a **Ruby** development environment which is supported by Bridgetown.

2. Install **Node** and **Yarn** to handle frontend assets and spin up a live-reload development server.

3. Install **Bridgetown** and related gems:
{%- if bridgetown.version contains "beta" %}
```
$ gem install bundler -N
$ gem install bridgetown -N -v {{ bridgetown.version }}
```
{%- else %}
```
$ gem install bundler bridgetown -N
```
{%- endif %}

4. Create a new Bridgetown site at `./mysite`.
```
$ bridgetown new mysite
```

5. Change into your new directory.
```
$ cd mysite
```

6. Build the site and run a live-reload development server:
```
$ yarn start
```

7. Browse to [http://localhost:4000](http://localhost:4000){:target="_blank"}

8. And you're done! (That's the goal at least 😊)

If you encounter any errors during this process, try revisiting your installation and setup steps, and if all else fails, [reach out to the Bridgetown community for support](/docs/community/). Also, make sure you've installed the development headers and other prerequisites as mentioned in the [Requirements](/docs/installation/#requirements) section.

{% rendercontent "docs/note" %}
More detailed installation instructions for macOS, Ubuntu Linux, and Windows 10 are [available here](/docs/installation/#guides).
{% endrendercontent %}

Bridgetown comes with the `bridgetown` CLI tool as well as several Yarn scripts,
so be sure to read up on the [command line usage documentation](/docs/command-line-usage).

Also read up on [Bridgetown's Core Concepts](/docs/core-concepts/) to gain familiarity with the basic building blocks and workflow of Bridgetown.
