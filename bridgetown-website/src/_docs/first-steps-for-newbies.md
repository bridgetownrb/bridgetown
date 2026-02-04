---
order: 45
title: First Steps for Newbies
top_section: Setup
description: If Bridgetown is your first web framework
category: first-steps
---

You have just installed Bridgetown by following the [Getting Started][getting-started] guide. Great! Now what?

If you are not familiar with other web frameworks, your brand new site may seem confusing. Head to our [explanation][initial-files] to discover what all these files and folders are about!

## First posts and pages

If you want a "typical", simple blog, open the `src` folder and identify:
- the `_posts` folder, which will result in the `posts` collection when you add files in the format `YYY-MM-DD-title.md`. These will follow the layout `post.erb` contained in the `_layouts` folder.
- the `index.md`, `about.md` and `posts.md` pages, which will follow the layout `page.erb` contained in the `_layouts` folder.

For now, `index.md` and `about.md` are static pages, respectively a home page and an about page. You can edit their content to suit your blog.

`posts.md` contains an example of how to access the items in a collection.

![getting posts](/images/posts-each.png)

In this case, it will list the titles of all your posts, with links to the corresponding posts. You can also access other properties of your posts. For instance, `post.data.date` will give you the date. Any custom metadata that you specify in the front matter can be accessed in the same way.

> [!NOTE]:
> If you create custom metadata for one post, you will need to include the same data for all other posts, in order to access it with an `each` method. The best strategy, if not all posts need this specific data, is to add it in a `_defaults.yml` file at the top of your directory tree, and leave it empty there.

## A custom collection

If you want to create a custom collection, you will need to initialize it in the `config/initializers.rb` file. (See [detailed instructions here][custom-collections].)

Then, create a `_your-collection` folder under the `src` folder, and add your files in it. You can use an existing layout, or create a custom layout in the `layouts` folder.

Add a `your-collection.md` file under the `src` folder to create a collection page similar to the `posts.md` page.

Edit the `components/shared/navbar.erb` file to add your new collection to the navigation bar (you can follow the format used for pages and posts).

![navbar](/images/navbar.png)

Now, you can add your content, either as a page, a post, or an item in a custom collection. But how will it look?

## Looking good

Bridgetown comes with a decent default theme. You can edit the CSS directly in `frontend/styles/index.css`.

You can also search the web for CSS themes, and either place the contents of the theme's CSS file in index.css, or follow the theme's installation instructions (for instance [pico][pico-theme])

## What next?

You now have a basic Bridgetown site set up, and you can focus on what matters most: your content.

When you are ready for more complex stuff, we recommend taking a look at Bridgetown's [bundled configurations][bundled-configurations] and [how to deploy to production][deploy].

<!--LINKS-->

[getting-started]: https://www.bridgetownrb.com/docs
[initial-files]: /docs/initial_files
[custom-collections]: https://www.bridgetownrb.com/docs/collections#custom-collections
[pico-theme]: https://picocss.com/docs#install-manually
[bundled-configurations]: https://www.bridgetownrb.com/docs/bundled-configurations
[deploy]: https://www.bridgetownrb.com/docs/deployment
