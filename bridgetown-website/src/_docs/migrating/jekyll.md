---
title: Migrating from Jekyll
top_section: Introduction
category: migrating
back_to: migrating-from
order: 0
---

While Bridgetown still bears some conceptual similaries to Jekyll, quite a lot has changed including the basic folder structure. Our recommendation is that, rather than try to transform an existing Jekyll repo into a Bridgetown one, you create **a new Bridgetown site from scratch** and then copy various files and content over from your Jekyll project in a systematic fashion.

Here are some steps you can take to do just that:

1. After installing Bridgetown, run `bridgetown new` to create your blank repo. The `frontend` folder is for saving frontend assets (CSS, JavaScript, fonts, and possibly images), the `src` folder is for content and static files (which also may include images), and the `plugins` folder is for any custom Ruby plugins you want to add. If much of your content is primarily in Markdown or HTML file, you shouldn't have much difficulty loading them in with Bridgetown. We also support data files (YAML, JSON, CSV) in a similar fashion.
2. For metadata like your site title, email address, seo defaults, whatever, you'll want to put those in `src/_data/site_metadata.yml` rather than in the main config file.
3. Unless you already know you need to use Webpack for a particular reason, we recommend sticking with the default esbuild configuration. With esbuild, you can import both Sass files and vanilla CSS files which are processed through PostCSS. Unlike with Jekyll, Bridgetown's frontend pipeline via esbuild requires you to define all your imports from the entrypoints (`index.js` or `index.(s)css`). Typically there's no automatic concatenation of files within the `frontend` folders.
4. You can copy your Liquid layouts over to `src/_layouts` , and other content can go into similar places within `src`. You'll need to update your Liquid code to use resources—for example, instead of looping through `site.posts` you'll loop through `collections.posts.resources`. And instead of `page.url` you'll need to write `page.relative_url`.
5. Jekyll includes will need to be converted to Liquid components inside of `src/_components` which are accessed via the `render` tag.
6. Plugins will need to be updated to use Bridgetown APIs. Some "legacy" APIs are still supported (like generators) and hooks work in a similar fashion. Be sure to use the right class names and module namespaces so that your code is compatible with the Zeitwerk autoloader.
7. For some third-party gems you might be using in your Jekyll project, there could be Bridgetown equivalents (jekyll-feed -> bridgetown-feed).
8. Bridgetown's theming system is different from Jekyll. You can either pull theme files (content, stylesheets, etc.) directly into your project and use them that way, or you can create a new gem-based Bridgetown theme.


## Additional Notes:

To build a Bridgetown site, run `bin/bridgetown build` (`bin/bt b` for short). To start a server, run `bin/bridgetown start` (`bin/bt s` for short). And for deployment builds, you'll want to run `bin/bridgetown deploy` and make sure the `BRIDGETOWN_ENV` environment variable is set to `production`.

There's no special "drafts" folder or draft mode for content in Bridgetown. You can simply set certain items to `published: false`, and in order to see those items locally in order to preview, pass the `--unpublished` or `-U` command line option.

The behavior of pages vs. posts vs. custom collection items is much closer and more predictable due to the revamped "resource" content engine in Bridgetown. There's literally a `pages` collection now (you can either store pages directly in the `src` folder or within the `_pages` subfolder), and you can configure custom collections to behave identially to the `posts` collection if you so with. Custom collection items can contribute categories and tags to the overall site (they're not posts-only).

Permalinks are formatted a bit differently now. You'll want to end your permalink templates with either a slash `/` (preferred) or a wildcard `.*` in order to ensure the appropriate extension is used.