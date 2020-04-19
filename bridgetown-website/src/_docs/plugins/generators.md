---
title: Generators
hide_in_toc: true
order: 0
category: plugins
---

{% render "docs/help_needed", page: page %}

You can create a generator when you need Bridgetown to create additional content
based on your own rules.

A generator is a subclass of `Bridgetown::Generator` that defines a `generate`
method, which receives an instance of
[`Bridgetown::Site`]({{ site.repository }}/blob/master/bridgetown-core/lib/bridgetown-core/site.rb). The
return value of `generate` is ignored.

Generators run after Bridgetown has made an inventory of the existing content, and
before the site is generated. Pages with front matter are stored as
instances of
[`Bridgetown::Page`]({{ site.repository }}/blob/master/bridgetown-core/lib/bridgetown-core/page.rb)
and are available via `site.pages`. Static files become instances of
[`Bridgetown::StaticFile`]({{ site.repository }}/blob/master/bridgetown-core/lib/bridgetown-core/static_file.rb)
and are available via `site.static_files`. See
[the Variables documentation page](/docs/variables/) and
[`Bridgetown::Site`]({{ site.repository }}/blob/master/bridgetown-core/lib/bridgetown-core/site.rb)
for details.

For instance, a generator can inject values computed at build time for template
variables. In the following example, the template `reading.html` has two
variables `ongoing` and `done` that are filled in the generator:

```ruby
module Reading
  class Generator < Bridgetown::Generator
    def generate(site)
      ongoing, done = Book.all.partition(&:ongoing?)

      reading = site.pages.detect {|page| page.name == 'reading.html'}
      reading.data['ongoing'] = ongoing
      reading.data['done'] = done
    end
  end
end
```

The following example is a more complex generator that generates new pages. In this example, the generator will create a series of files under the `categories` directory for each category, listing the posts in each category using the `category_index.html` layout.

```ruby
module MySite
  class CategoryPageGenerator < Bridgetown::Generator
    def generate(site)
      if site.layouts.key? 'category_index'
        dir = site.config['category_dir'] || 'categories'
        site.categories.each_key do |category|
          site.pages << CategoryPage.new(site, site.source, File.join(dir, category), category)
        end
      end
    end
  end

  # A Page subclass used in the `CategoryPageGenerator`
  class CategoryPage < Bridgetown::Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
      self.data['category'] = category

      category_title_prefix = site.config['category_title_prefix'] || 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category}"
    end
  end
end
```

Generators need to implement only one method:

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Method</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>generate</code></p>
      </td>
      <td>
        <p>Generates content as a side-effect.</p>
      </td>
    </tr>
  </tbody>
</table>

If your generator is contained within a single file, it can be named whatever you want but it should have an `.rb` extension. If your generator is split across multiple files, it should be packaged as a Rubygem to be published at https://rubygems.org/. In this case, the name of the gem depends on the availability of the name at that site because no two gems can have the same name.

By default, Bridgetown looks for generators in the `plugins` directory. However, you can change the default directory by assigning the desired name to the key `plugins_dir` in the config file.
