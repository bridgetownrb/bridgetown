---
title: Prototype Pages
order: 15
top_section: Content
category: prototype_pages
---

This feature builds upon the [Pagination functionality](/docs/content/pagination/) and
lets you create automatically generated, paginated archives of your content filtered by
the search terms you provide. For instance you could set it up so every category has its
own page, every tag has its own page, or virtually any other search term.

Note that in order to use [pagination](/docs/content/pagination/), you'll need to enable it your site's `bridgetown.config.yml`.

{% toc %}

# Simple Usage

All you need to do is create a page, say `categories/category.html`, and add a
`prototype` config to the Front Matter:

```yaml
---
layout: default
title: Posts in category :prototype-term
prototype:
  term: category
```

And then all the site's different categories will have archives pages at this location
(e.g. `categories/awesome-movies`, `categories/my-cool-vacation`, etc.). And it enables
pagination automatically, so you'd just use `paginator.documents` to loop through the
posts like on any normal paginated page. Using `:prototype-term` in the page title will
automatically put each archive page's term (aka the category name) in the output title.

You can do the same thing with tags—just use `term: tag` and create a `tags/tag.html`
file. The exact folder/filename doesn't actually matter—you could create
`my-super-awesome-tagged-content/groovy.html` and it would still work. (The filename
always gets replaced by the search term itself.)

If you want to "titleize" the search term in the processed `title` variable, use
`:prototype-term-titleize`. Thus given the category "cool-vacation":

```yaml
---
title: Posts in category :prototype-term-titleize
prototype:
  term: category
```

You'd get `Posts in category Cool Vacation` as the page title.

In addition, the search term used for each generated page is placed into a Liquid
variable, so you can use that as well in your template: `page.category`, or `page.tag`,
etc.

## Searching in Collections

You can also search in collections other than the default (posts) by including that in
the prototype configuration:

`tigers/countries/country.html`
```yaml
---
title: Tigers in country :prototype-term-titleize
prototype:
  term: country
  collection: tigers
```

`/_tigers/bengal.md`
```yaml
---
title: Bengal Tiger
country: India
```

This would produce a generated `tigers/countries/india` page that loops through
all the tigers in `India`.


# Pulling in Site Data

Prototype pages can be configured to load in extra data from [data files](/docs/datafiles/)
that are matched with the search term. This is great for common uses like listing out
every post by each of the authors in the site.

Here's an example of how that works:

`_posts/2020-04-10-article-by-jared.md`
```liquid
---
title: I'm an article
author: jared
---

Content goes here.
```

`_data/authors.yml`
```yaml
jared:
  name: Jared White
  twitter: jaredcwhite
```

`authors/author.html`
{% raw %}
```liquid
---
layout: default
title: Articles by :prototype-data-label
prototype:
  term: author
  data: authors
  data_label: name
---


<h1>{{ page.title }}</h1> <-- Articles by Jared White -->

<h2>Twitter: @{{ page.author_data.twitter }}</h2> <!-- Twitter: @jaredcwhite -->

<!-- posts where author == jared -->

{% for post in paginator.documents %}
  {% include post.html %}
{% endfor %}
```
{% endraw %}

As you can image, the possibilities are endless!

## Permalinks

You can also customize the [permalinks](/docs/structure/permalinks/) used in Prototype
pages using `:term`. For example, using the Tigers example above, you could change the
URLs that get generated like so:

```yaml
---
title: Tigers in country :prototype-term-titleize
permalink: /animals/:term/tigers
prototype:
  term: country
  collection: tigers
```

And then you would get pages generated at `/animals/india/tigers`, `/animals/china/tigers`, etc.
