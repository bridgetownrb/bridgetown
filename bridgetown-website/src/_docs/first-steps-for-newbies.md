---
order: 45
title: First Steps for Newbies
top_section: Setup
description: If Bridgetown is your first web framework
category: first-steps
---

You have just installed Bridgetown by following the [Getting Started](https://www.bridgetownrb.com/docs) guide. Great! Now what?

If you are not familiar with other web frameworks, your brand new site may seem confusing. Head to our [explanation](/docs/initial_files) to discover what all these files and folders are about!

## First posts and pages

If you want a "typical", simple blog, open the `src` folder and identify:
- the `_posts` folder, which will result in the `posts` collection when you add files in the format `YYY-MM-DD-title.md`. These will follow the layout `post.erb` contained in the `_layouts` folder.
- the `index.md`, `about.md` and `posts.md` pages, which will follow the layout `page.erb` contained in the `_layouts` folder.

For now, `index.md` and `about.md` are static pages, respectively a home page and an about page. You can edit their content to suit your blog.

`posts.md` contains an example of how to access the items in a collection.

```erb
<ul>
  <% collections.posts.each do |post| %>
    <li>
      <a href="<%= post.relative_url %>"><%= post.data.title %></a>
    </li>
  <% end %>
</ul>
```

In this case, it will list the titles of all your posts, with links to the corresponding posts. You can also access other properties of your posts. For instance, `post.data.date` will give you the date. 

This metadata is as versatile as you need it to be! You can create custom metadata in the [front matter](https://www.bridgetownrb.com/docs/front-matter) and access it in the same way with `post.data.order` or `post.data.category`.

```yaml
---
order: 45
title: First Steps for Newbies
top_section: Setup
description: If Bridgetown is your first web framework
category: first-steps
---
```

> [!NOTE]:
> If you create custom metadata for one post, you will need to include the same data for all other posts. If not all posts need this specific data, it is best to add it in a `_defaults.yml` file in your `_posts` directory, and leave it empty there.

## A custom collection

If you want to create a custom collection (let's say "Docs" for your documentation), you will need to initialize it in the `config/initializers.rb` file. (See [detailed instructions here](https://www.bridgetownrb.com/docs/collections#custom-collections).)

```ruby
Bridgetown.configure do |config|
  collections do
    docs do
      output true
    end
  end
end
```

Then, create a `_docs` folder under the `src` folder, and add your documentation files in it. You can use an existing layout, or create a [custom layout](https://www.bridgetownrb.com/docs/layouts) in the `layouts` folder.

Add a `docs.md` file under the `src` folder to create a collection page similar to the `posts.md` page. You can create a list of docs, filtered by metadata, by accessing `collections.docs.each do |doc|`, just like for the posts above.

Edit the `components/shared/navbar.erb` file to add your new collection to the navigation bar (you can follow the format used for pages and posts).

```erb
<nav>
  <ul>
    <li><a href="<%= relative_url '/' %>">Home</a></li>
    <li><a href="<%= relative_url '/about' %>">About</a></li>
    <li><a href="<%= relative_url '/posts' %>">Posts</a></li>
    <li><a href="<%= relative_url '/docs' %>">Docs</a></li>
  </ul>
</nav>
```

Now, you can add your content, either as a page, a post, or an item in a custom collection. But how will it look?

## Looking good

Bridgetown comes with a decent default theme. You can edit the CSS directly in `frontend/styles/index.css`.

You can also search the web for CSS themes, and either place the contents of the theme's CSS file in index.css, or follow the theme's installation instructions (for instance [pico](https://picocss.com/docs#install-manually))

## What next?

You now have a basic Bridgetown site set up, and you can focus on what matters most: your content.

To make your site more accessible on the Web, consider adding the [SEO](/docs/bundled-configurations#seo) and [Feed](https://www.bridgetownrb.com/docs/bundled-configurations#feed) bundled configurations (instructions in the links).

When you're ready to publish your site, head over to our [deployment guide](/docs/deployment).
