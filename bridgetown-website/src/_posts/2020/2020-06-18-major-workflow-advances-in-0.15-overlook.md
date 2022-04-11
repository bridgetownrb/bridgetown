---
title: "Huge Theme and Workflow Advances in Bridgetown 0.15 “Overlook”"
subtitle: Introducing themes, automations, Liquid Components, testing strategies, and a new Thor-based CLI—all to make your experience building Bridgetown sites a true delight.
author: jared
category: release
---

Whew, a lot has happened since the release of Bridgetown 0.14 "Hazelwood". The community has been growing [on Twitter](https://twitter.com/bridgetownrb) and [in Discord](https://discord.gg/V56yUWR), we've gotten [new sponsors on GitHub](https://github.com/bridgetownrb/bridgetown#special-thanks-to-our-founding-members--), and a ton of work to move the ecosystem forward has been going on behind the scenes.

It's time to unveil some of those initiatives today with the release of Bridgetown 0.15 "Overlook"!

### Overview Video

Before we get into the meat of the release, there's a brand-new overview video you can watch to learn more about Bridgetown!

<figure>
  <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/gSij_P3iaIE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen loading="lazy"></iframe>
</figure>

This is the first video in an ongoing series, so keep an eye out for future installments.

### Themes, Plugins, and Automations

While technically you could previously author a Gem-based plugin that would act as a theme for a Bridgetown site, there was a general lack of handholding for both the developer trying to set up the theme and the user trying to install the theme.

In 0.15, we've fixed both sides of this equation. First of all, we completely rewrote the Bridgetown CLI from the ground up (migrating from the Mercenary gem to the Thor gem). Because of this, we're able streamline and enhance all of the builtin commands as well as make it easier for plugins to supply new commands going forward.

You can now run `bridgetown plugins new` to create a new plugin folder directly with your own custom name right out of the gate. [This is a great way to get started authoring a plugin _or_ a theme.](/docs/plugins) Also in the next week or so, I (Jared) will be releasing a BulmaCSS-based Bridgetown theme which you can refer to as an example of how to build a theme.

Secondly, we've introduced a brand-new feature called [Automations](/docs/automations). You can write automation scripts which act on new or existing sites to perform tasks such as adding gems, updating configuration, inserting code, copying files, and much more.

Automations are similar in concept to Gatsby Recipies or Rails App Templates. They’re uniquely powerful when combined with plugins, as an automation can install and configure one or more plugins from a single script. This is quite helpful for themes as well, as you can guide a user through the entire setup process for the theme right from the command line.

We also fixed a few bugs related to installing a plugin's NPM package via Yarn, so at this point we feel pretty confident saying the whole theme/plugin subsystem is now ready for primetime.

### Design Systems with Liquid Components

We could have stopped there, but we didn't! We've also shipped a "1.0" implementation of [Liquid Components](/docs/components) and deprecated the previous `include` tag functionality.

Liquid Components let you design your site using discrete, modular building-blocks. Similar in concept to components found in frontend frameworks, you can use these building-blocks to create buttons, cards, boxes, tables, navbars, headers, footers, and other parts comprising a comprehensive design system for your site. You can even combine Liquid Components with Web Components for a one-two punch that offers static rendering and frontend interactivity all in one package. This is true for components in your own site repo as well as for plugins.

As an example of a plugin which provides such a hybrid component, check out the brand new [Quick Search plugin](https://github.com/bridgetownrb/bridgetown-quick-search) available to all Bridgetown 0.15+ sites. In minutes you can drop in a search bar component and have live search working across all your pages, blog posts, and other collection documents. (The search box up top on this website is an example of that plugin in action!)

We think this is a great way to bring Ruby static site generation methodology up to snuff with the latest best-practices in web development, and we can't wait to see what you all come up with!

### Test Your Site with an Automated Test Suite

Speaking of best practices, one of the benefits of deploying Jamstack sites using a build process is you can insert an automated test suite into that workflow. And we've got not one but _two_ different [test strategies ready for you](/docs/testing) to add to your sites!

For an _extremely fast_ method of testing the validity of your output HTML, you can now set up a Ruby + Minitest suite via a simple automation. Using standard DOM assertions borrowed from Rails, you can verify parts of pages and templates right at the point they've all been rendered in memory, and if the tests fail, hosting platforms such as Netlify will halt the deployment so your invalid site won't complete the deployment.

For a slower but more comprehensive E2E (end-to-end) test suite, you can install Cypress and test your site via its headless browser technology. Use this to literally click around, input text into form fields, navigate between pages, and make sure everything is working as designed.

### The Magic of Open Source

One last announcement to make—some of the nifty treats in v0.15 you were just reading about were contributed by [ParamagicDev on GitHub](https://github.com/ParamagicDev), and the cool part is that Bridgetown was the _first project_ to benefit from a code PR (pull request) he submitted! w00t!

We're thrilled to be attracting both new and long-time fans of the Ruby programming language—and we look forward to Bridgetown's continued invigoration of the Ruby ecosystem long into the future.

### Get Started with Bridgetown

So enough with the technobabble. [Give Bridgetown a spin](/docs) and [let us know what you think](/community)!

Also check out [our Core Concepts guide](/docs/core-concepts) to learn more about the fundamentals of Bridgetown.

And stay tuned for further tutorials and community plugin news in the weeks ahead!
