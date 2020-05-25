---
title: What’s a Jamstack?
order: 21
top_section: Philosophy
category: jamstack
---

According to [Jamstack.org](https://jamstack.org), it's a unique approach to building websites and software for the web:

{:.my-8}
> **Fast and secure sites and apps delivered by pre-rendering files and serving them directly from a CDN, removing the requirement to manage or run web servers.**

Jamstack sites deliver better performance, higher security, lower cost of scaling, and a superior developer experience.

## Comparison

How does the Jamstack compare with another type of system, such as a monolithic CMS (Content Management System) like WordPress or a bespoke application built in a framework like Ruby on Rails?

* **Single App Stack: Built Upon Each Request.** WordPress, Ruby on Rails, Node, Squarespace, etc. are all designed to run as server software that delivers website content to site visitors at the moment they request it. In other words, when a web browser goes to a specific page, the server software has to generate that page on the spot and send it to the browser.

* **Jamstack: Pre-Built When Content Updates.** A Jamstack website is instead served from a CDN (Content Delivery Network) or standard filesystem rather than a dynamic application server. That means when a visitor opens up a Jamstack site, the essential design and content is _not being generated_ on-the-fly, but rather is coming from a _recent, pre-built_ static snapshot. The speed at which that data transfer can happen and the simplicity of scaling that solution to thousands or even millions of users is an order of magnitude simpler (and cheaper) than the dynamic server approach.

* **Jamstack Interactivity is Added On.** If you do need to add interactivity and fresh real-time information to a Jamstack site, you would need to use Javascript to load data from an API (Application Programming Interface). You can build an API yourself or employ any number of third-party APIs (including public data services). Using the web development best practice known as _Progressive Enhancement_, you'd build your site for the static snapshot use case **first**, and then add layers of additional interactivity on top **second** (with the goal being any sort of temporary API failure won't terribly degrade the basic website experience).

{:.mt-12}
## "JAM" (Javascript, APIs, Markup) Stack

Because **Bridgetown** is a Jamstack framework/site generator, this is how you'd go about developing a website. The process is essentially reversed from the catchy acronym JAM: you start with the markup and work your way up to dynamic frontend functionality.

**Markup.** You start by defining the HTML templates of your website and writing CSS to lay elements out on the page, set typography, and add other graphical enhancements. You author content (blog posts, informational pages, structured data collections, etc.) in simple formats like Markdown, YAML, CSV, JSON, etc., and that content gets automatically converted to final HTML whenever **Bridgetown** is instructed to build the site for deployment.

**APIs.** If you need to pull in data from external sources, or interact with online services via user input, you'll need to find or write one or more APIs. APIs come in many shapes and sizes. Since **Bridgetown** is written in Ruby, one possibility is to use Ruby on Rails to build a custom API, and then use that API either during the website build process (thus "baking" the API's data into the static snapshot for deployment) or on-the-fly via Javascript (see below). But you can write an API using any virtually any language or framework…Node, Python, Go, you name it. Or find a third-party web service which lets you use or adapt existing APIs.

**Javascript.** The final piece of the puzzle…frontend Javascript lets you write interactive components and modules that add fresh information to a webpage, capture and process input from users, and otherwise enhance the functionality of your website. Remember, it's best to try as much as possible to provide a working site _without_ Javascript running, and then use Javascript to add new features on top of the basic experience. There are many popular Javascript frameworks available, and by utilizing the Webpack bundler tool, **Bridgetown** lets you easily add one of your choosing—whether it be [Stimulus](https://stimulusjs.org), [Alpine](https://github.com/alpinejs/alpine/), [Vue](https://vuejs.org), [React](https://reactjs.org), [LitElement](https://lit-element.polymer-project.org), or vanilla [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components).

{:.mt-12}
## How Do You Edit and Publish Content with the Jamstack?

There are typically three different ways to author, manage, save, and publish website content when working with Jamstack sites. Some are easier for programmers, others are easier for visually-focused content creators and editors.

0. **Save Files in the Git Repository.** Because Jamstack sites are typically located in a version-controlled code repository using Git, and saved onto a central repo service such as GitHub, you can clone the site files directly to your device, add Markdown posts and other site content, and _commit_ those changes to the repository. Once you _push_ those changes back up to GitHub (for example), that usually triggers an automated build process to publish the latest changes to the web. Jamstack-focused services such as [Netlify](https://www.netlify.com) are a great way to build and publish the website. Unlike hosting services of the past, Netlify's starting price can't be beat: **it's free** 😁.

0. **Use a CMS-like editing interface.** There is a growing number of tools which provide a familiar visual editing interface on the web, but under the hood modify the same files in the repo (Markdown posts, data collections, etc.) much like the first process above. Examples of these kinds of tools are Forestry, Siteleaf, Netlify CMS, and many others.

0. **Store content inside a "headless" CMS.** This utilizes a process closest to the previous era of dynamic CMS applications. With what's called a "headless" CMS, you author content interactively using the CMS, and content is stored in that CMS' database. When content is ready to get published, a build process is triggered for the Jamstack site generator (aka **Bridgetown**), but at that point the generator uses the headless CMS' API to download all relevant data and produce the final website for deployment. There are many headless CMS tools available, and you can even use WordPress itself as one! (Although that's not typically recommended… 😋)

{:.mt-12}
## How Do I Get Started Building a Jamstack Website?

We're biased, of course, but our recommendation is simple: install **Bridgetown**, run `bridgetown new` to create a blank site repository, and start customizing your HTML templates, adding a fun CSS framework like Bulma or Tailwind, and authoring some content. Once you have something you like, simply push the repository up to GitHub, connect the repo up to a Jamstack hosting service like Netlify, and deploy. That might sound like a daunting sequence of steps, but once you get the hang of it the whole process might only take up a breezy afternoon. (Some of us remember spending hours just wrestling with MySQL databases and WordPress theme files! The future is bright, folks! 😃🎉)

{:.has-text-centered.mt-10}
[Get Started](/docs/){:.button.is-large.is-info}

