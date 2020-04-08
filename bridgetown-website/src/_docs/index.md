---
order: 1
title: Getting Started
top_section: Introduction
category: intro
---

In a nutshell, Bridgetown is a **static site generator**. You give it text written in an author-friendly markup language like Markdown, and it uses layouts and templates to build a website and save the compiled HTML, CSS, and Javascript to an output folder. You can tweak how you want the pages to look, what data gets displayed on the site, and more.

Bridgetown works best as part of a version-controlled repository powered by Git. You can centrally store your repository on a service like GitHub so that you and everyone else working on the website (plus your hosting provider) all have direct, secure access to the latest website content and design files.

During the development process, you will likely be running Bridgetown from the command line on your local developer machine (or perhaps a remote staging server). Once content is ready to publish, you would commit your website codebase to the Git repository and use an automated build tool to generate and upload the final output to a server or CDN (Content Delivery Network). [Netlify](https://www.netlify.com) is a popular service for this, but there are many others. You can also just literally copy the generated files contained in the `output` folder to any HTTP web server and it should Just Work. 😊

## Quick Instructions

Read [requirements]({{ '/docs/installation' | relative_url }}) for more information on what you'll need to have set up in advance.

The basic installation process is as follows:

1. Install a **Ruby** development environment which is supported by Bridgetown.
2. Install **Node** and **Yarn** to handle frontend assets.
3. Install **Bridgetown** and related gems.
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
6. Install Bridgetown builder and frontend dependencies.
```
$ bundle install
$ yarn install
```
7. Build the site and make it available on a local server.
```
$ yarn build && bundle exec bridgetown serve
```
8. Browse to [http://localhost:4000](http://localhost:4000){:target="_blank"}
9. And you're done! (That's the goal at least…)

If you encounter any errors during this process, see the
[troubleshooting]({{ '/docs/troubleshooting/#configuration-problems' | relative_url }}) page. Also, make sure you've installed the development headers and other prerequisites as mentioned on the [requirements]({{ '/docs/installation/#requirements' | relative_url }}) page.