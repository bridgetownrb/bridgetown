---
title: Generators
hide_in_toc: true
order: 0
category: plugins
---

You can write a generator when you need Bridgetown to add data to existing content
or to programmatically create new pages, posts, and the like.

You define a generator by subclassing `Bridgetown::Generator`. It accepts a
single `generate` method, which receives an instance of
[`Bridgetown::Site`](https://github.com/{{ site.metadata.github }}/blob/master/bridgetown-core/lib/bridgetown-core/site.rb). (The return value of `generate` is
ignored.) Within this `generate` method, you have free reign to modify existing
content or add new content.

Generators run after Bridgetown has made an inventory of the existing content, but
before the site is rendered out. Pages with front matter are stored as instances of
[`Bridgetown::Page`](https://github.com/{{ site.metadata.github }}/blob/master/bridgetown-core/lib/bridgetown-core/page.rb)
and are available via `site.pages`. Static files become instances of
[`Bridgetown::StaticFile`](https://github.com/{{ site.metadata.github }}/blob/master/bridgetown-core/lib/bridgetown-core/static_file.rb)
and are available via `site.static_files`. See
[the Variables documentation page](/docs/variables/) and
[`Bridgetown::Site`](https://github.com/{{ site.metadata.github }}/blob/master/bridgetown-core/lib/bridgetown-core/site.rb)
for more details.

## Adding Data to Existing Pages

A generator can inject values computed at build time into page variables. In the
following example, the page `reading.html` will have two variables `ongoing` and `done`
that get added via the generator:

```ruby
module Reading
  class Generator < Bridgetown::Generator
    def generate(site)
      book_status = remote_data # perhaps fetching data from an API

      reading = site.pages.detect {|page| page.name == 'reading.html'}
      reading.data['ongoing'] = book_status.ongoing
      reading.data['done'] = book_status.done
    end
  end
end
```

## Creating New Pages

The following example is a more complex generator that generates new pages. In this
example, the generator will create a series of files under the `categories` folder for
each category, listing the posts in each category using the `category_index.html` layout.

*src/_layouts/category_index.html:*
{% raw %}
```liquid
---
---

Title: {{ page.title }}

Category: {{ page.category }}

# of Posts: {{ page.posts.size}}

Posts:
{% for post in page.posts %}
  {{ post.title }} ({{ post.url }})
{% endfor %}
```

*plugins/category_pages.rb:*
```ruby
module MySite
  class CategoryPageGenerator < Bridgetown::Generator
    def generate(site)
      if site.layouts.key? "category_index"
        site.categories.each_key do |category|
          site.pages << CategoryPage.new(site, category)
        end
      end
    end
  end

  # A Page subclass used in the `CategoryPageGenerator`
  class CategoryPage < Bridgetown::Page
    def initialize(site, category)
      @site = site
      @base = site.source # start in src
      @dir  = "categories/#{category}" # aka src/categories/<category>
      @name = "index.html" # filename
      process(@name) # saves internal filename and extension information

      # Load in front matter and content from the layout
      read_yaml("_layouts", "category_index.html")

      # Inject data into the generated page:
      data["category"] = category
      data["title"] = "Category: #{category}"
      data["posts"] = site.posts.docs.select do |post|
        post.data["categories"].include? category
      end
    end
  end
end
```
{% endraw %}

Normally the final URL of the generated page will be determined via standard permalink
logic (just as if the page were literally saved in the source folder), but if you want
programmatic control over the URL in your page subclass, simply set the `@url` instance
variable in your page initializer.

{% rendercontent "docs/note" %}
By default, Bridgetown looks for generators in the `plugins` folder. However, you can
change the default folder by assigning the desired name to the key `plugins_dir` in the
config file.
{% endrendercontent %}
