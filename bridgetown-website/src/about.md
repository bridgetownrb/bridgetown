---
layout: page
title: The History and Future of Bridgetown
---

Bridgetown started life as a fork of the granddaddy of static site generators, [Jekyll](https://jekyllrb.com). Jekyll came to prominence in the early 2010s due to its slick integration with GitHub, powering thousands of websites for developer tools. In the years since it has grown to provide a popular foundation for a wide variety of sites across the web.

But as the concepts of modern static site generation and the [Jamstack](/docs/jamstack/) came to the forefront, a whole new generation of tools rose up, like [Hugo](https://gohugo.io), [Eleventy](https://www.11ty.dev), [Gatsby](http://gatsbyjs.org), and many more. In the face of all this new competition, Jekyll chose to focus on maintaining extensive backwards-compatibility and a slim feature set—noble goals for an open source project generally speaking, but ones that were at odds with significant portions of the web developer community.

So in March 2020, Portland-based web studio [Whitefusion](https://whitefusion.io) started on **Bridgetown**, a fork of Jekyll with a brand new set of project goals and a future roadmap. Whitefusion's multi-year experience producing and deploying numerous Jekyll-based websites furnishes a seasoned take on the unique needs of web agencies and their clients.

It's early days yet, but our goal is to keep adding new features at a steady and predictable pace, grow the open source community around the project, and ensure a healthy future for a top-tier Ruby-based static site generator moving forward.

## Roadmap

As of spring 2020, here is the vision for where Bridgetown is headed. And this is just a start! If you have [ideas and feature requests (and code!) to contribute](/docs/community/#ways-to-contribute), let's do it! [You can also take a look at our Project Goals page.](/docs/philosophy/)

{:.note}
- _DONE!_ **Retool the codebase** into a monorepo of multiple gems (like Rails/Spree/etc.)
- _DONE!_ **Improve default site file/folder structure** to bring Bridgetown in line with other popular static site generators.
- _DONE!_ Add a **console command** to interactively interact with site data and plugins (like the Rails console).
- _DONE!_ Remove the aging asset pipeline and **regroup around a modern solution: Webpack**. (Similar to how Rails adopted Webpack and distanced itself from Sprockets.)
  - Add additional commands to **further cement the Webpack build process** into the Bridgetown build process.
- _IN PROGRESS…_ Ensure all **documentation, configuration, and deployment recommendations are fully up-to-date** and in line with best practices encouraged by the web development industry.
- _IN PROGRESS…_ External theme support has been temporarily removed from the codebase, because we want to add the **ability for any Bridgetown plugin gem to provide content/design**. That will bring back “themes” but in a way that’s composable and more flexible.
- _IN PROGRESS…_ **Components!** This would build upon the existing `include` tag functionality and add a ton of new features to make component-based design and authoring a reality, bringing Ruby/Liquid syntax closer to the world of React & Vue. Ready for "Bridgebook"?? 😁 (aka our take on Storybook.js)
- Straightforward support for **third-party data APIs** (think GraphQL as a first-class citizen).
- Easy **multilingual setup** right out of the box.
- Add a streamlined **pagination and archive page (for category and tags) solution** to Bridgetown Core.
- Move most site-level data vars to a **reloadable file** (like _data/site_settings.yml) and allow for env-specific settings.
- **Simple webhooks** — allow remote webhooks to be pinged after a successful build.
  - **“Private” pages** — aka put a website section behind a randomized URL that changes frequently and then allow that to be pinged to a web hook somewhere.
- **Auto-reload plugins** during development. (No more stop-and-restart every 5 seconds!)
- Continued improvement of the incremental site generator for **lightning-fast page previews**.
- Official **site testing framework** to verify content and functionality after new builds.
- _LONGSHOT…_ **Rails engine** for Bridgetown — it's a missed opportunity that Rails doesn't have a good Jamstack story. This would explore the ability to load and manipulate site content and trigger new builds from within any Rails-based application.
- _LONGSHOT…_ Investigate potentially huge wins regarding **headless CMS + Bridgetown integrations** as officially recommended plugins.
- _LONGSHOT…_ Use the new Liquid Components support to enable a **drag-and-drop visual page builder** plugin.

And as an open source project in general, we want to be good stewards of the codebase and community, which starts with striving for a predictable release schedule. Our goal is that there would be a:

- Major release every six-to-eight months (1.1, 1.2, 2.0, etc.)
- Minor releases at least once a month, hopefully more (1.2.5, 1.2.6)

We also want to ensure Bridgetown is a reliable partner for commercial solution providers by ensuring their frontline work with clients goes well and feedbacks positively into the Bridgetown feature set. What does this mean in a nutshell? It means if you make a living building websites using Bridgetown and run into major workflow hiccups, [we want to know about it](/docs/community/).

**So, ready to try out Bridgetown for yourself?**

{:.has-text-centered.mt-10}
[Get Started](/docs/){:.button.is-large.is-info}
