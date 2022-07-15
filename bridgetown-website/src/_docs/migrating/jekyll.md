---
title: Migrating from Jekyll
top_section: Introduction
category: migrating
back_to: migrating-from
order: 0
---

While Bridgetown still bears conceptual similarities to Jekyll at first glance, quite a lot has changed. ([Just read this rundown of 40 new and enhanced features!](/docs/migrating/features-since-jekyll)) The default folder structure of a Bridgetown website is a bit different as well. Our recommendation is that, rather than try to transform an existing Jekyll repo into a Bridgetown one, you **create a new Bridgetown site from scratch** and then copy various files and content over from your Jekyll project in a systematic fashion.

Here are some steps you can take to do just that:

1. **Create your project.** After [installing Bridgetown](/docs/installation), run `bridgetown new` to create your blank repo. The `frontend` folder is for saving frontend assets (CSS, JavaScript, fonts, and possibly images), the `src` folder is for content and static files (which also may include images), and the `plugins` folder is for any custom Ruby plugins you want to add. If much of your content is primarily in Markdown or HTML file, you shouldn't have much difficulty loading them in with Bridgetown. We also support data files (YAML, JSON, CSV) in a similar fashion. [More docs here.](/docs/structure)
2. **Set up your metadata.** For metadata like your site title, email address, seo defaults, whatever, you'll generally want to put those in `src/_data/site_metadata.yml` rather than in the main config file. The bonus is, you can change these values and live reload will allow you to preview your changes in real-time. [More docs here.](/docs/datafiles)
3. **Review your frontend bundling setup.** Unless you already know you need to use Webpack for a particular reason, we recommend sticking with the default esbuild configuration. With esbuild, you can import both Sass and vanilla CSS files which are then processed through PostCSS. Unlike with Jekyll, Bridgetown's frontend pipeline via esbuild requires you to define all your imports from the entrypoints (`index.js` or `index.(s)css`). Typically there's no automatic concatenation of files within the `frontend` folders. [More docs here.](/docs/frontend-assets)
4. **Need to create a theme?** Bridgetown's theming system is different from Jekyll. You can either pull theme files (content, stylesheets, etc.) directly into your project and use them that way, or you can create a new gem-based Bridgetown theme. [More docs here](/docs/themes)
5. **Copy over your content.** You can copy your Liquid layouts over to `src/_layouts` , and other content can go into similar places within `src`. You'll need to update your Liquid code to use resources—for example, instead of looping through `site.posts` you'll loop through `collections.posts.resources`. And instead of `page.url` you'll need to write `page.relative_url`. [More docs here.](/docs/resources)
6. **Update your includes.** Jekyll includes will need to be converted to Liquid components inside of `src/_components` which are accessed via the `render` tag. [More docs here.](/docs/components/liquid)
7. **Update your plugins.** Plugins will need to be updated to use Bridgetown APIs. Some "legacy" APIs are still supported (like generators) and hooks work in a similar fashion. Be sure to use the right class names and module namespaces so that your code is compatible with the Zeitwerk autoloader. [More docs here.](/docs/plugins)
8. **Find equivalent plugin gems.** For some third-party gems you might be using in your Jekyll project, there could be Bridgetown equivalents (jekyll-feed -> bridgetown-feed). [View the plugins directory.](/plugins/)
9. **Still stuck?** If you run into major roadblocks and just can't seem to get past the initial migration effort, we encourage you to [take advantage of our community support channels](/community) to help get you unstuck. Note that it's always much easier if you're able to share a repo link so someone can try to reproduce your issue and offer useful advice.

## Additional Points to Consider:

**Learn new commands.** To build a Bridgetown site, run `bin/bridgetown build` (`bin/bt b` for short). To start a server, run `bin/bridgetown start` (`bin/bt s` for short). And for deployment builds, you'll want to run `bin/bridgetown deploy` and make sure the `BRIDGETOWN_ENV` environment variable is set to `production`. And a very cool feature you'll be introduced to with Bridgetown: you can run `bin/bridgetown console` (`bin/bt c` for short) to boot up an IRB-based REPL where you can inspect your collections and data, interact with plugins, and test out various bits of Ruby code right there in your terminal. [More docs here.](/docs/command-line-usage)

**What about drafts?** There's no special "drafts" folder or draft mode for content in Bridgetown. You can simply set certain items to `published: false`, and in order to see those items locally in order to preview, pass the `--unpublished` or `-U` command line option.

**Content is less confusing.** The behavior of pages vs. posts vs. custom collection items is much closer and more predictable due to the revamped "resource" content engine in Bridgetown. There's literally a `pages` collection now (you can either store pages directly in the `src` folder or within the `_pages` subfolder), and you can configure custom collections to behave identically to the `posts` collection if you so with. Custom collection items can contribute categories and tags to the overall site (they're not posts-only). [Read more about collections.](/docs/collections)

**Mind your permalinks.** Permalinks are formatted a bit differently now. You'll want to end your permalink templates with either a slash `/` (preferred) or a wildcard `.*` in order to ensure the appropriate extension is used. [Read more about permalinks.](/docs/content/permalinks)

**You're no longer limited to Liquid.** Liquid is a fine template language to get started with, but more advanced site builds will quickly run into its limitations. With Bridgetown, you have the option to use ERB, plain Ruby, or other template languages like Serbea or Haml. In addition, you can write Ruby view components to DRY up much of your template code and create more of a disciplined design system. [Read more about templates](/docs/template-engines) and [components](/docs/components) to see what's possible.