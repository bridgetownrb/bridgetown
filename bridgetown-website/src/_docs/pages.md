---
title: Pages
order: 10
top_section: Content
category: pages
---

Pages are the most basic building block for content. They're useful for standalone
content (content which is not date based or is not a group of content such as staff
members or recipes).

The simplest way of adding a page is to add an HTML file in the source
folder (`src`) with a suitable filename. You can also write a page in Markdown using
a `.md` extension which converts to HTML on build. For a site with
a homepage, an about page, and a contact page, here’s what the source folder
and associated URLs might look like:

```
.
├── about.md    # => http://example.com/about.html
├── index.html    # => http://example.com/
└── contact.html  # => http://example.com/contact.html
```

If you have a lot of pages, you can organize them into subfolders. The same subfolders that are used to group your pages in your project's source will then exist in the `output` folder when your site builds. However, when a page has a *different* permalink set in the front matter, the subfolder at `output` changes accordingly.

```
.
├── about.md          # => http://example.com/about.html
├── documentation     # folder containing pages
│   └── doc1.md       # => http://example.com/documentation/doc1.html
├── design            # folder containing pages
│   └── draft.md      # => http://example.com/design/draft.html
```

## Changing the output URL

You might want to have a particular folder structure for your source files that changes for the built site. With [permalinks](/docs/structure/permalinks) you have full control of the output URL.

## Front Matter

[Front matter](/docs/front-matter) is a snippet of YAML which sits between two triple-dashed lines at the top of a file. Front matter is used to set variables for the page, for example:

```yaml
---
my_number: 5
---
```

Front matter variables are available in Liquid via the `page` variable. For example to output the variable above you would use:

```liquid
{% raw %}{{ page.my_number }}{% endraw %}
```

Note that in order for Bridgetown to process any Liquid tags on your page, you must include front matter on it. The most minimal snippet of front matter you can include is:

```yaml
---
---
```

[Learn more about front matter.](/docs/front-matter/)
