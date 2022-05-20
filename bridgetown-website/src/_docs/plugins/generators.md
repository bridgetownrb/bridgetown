---
title: Generators
order: 0
top_section: Configuration
category: plugins
---

You can write a generator when you need Bridgetown to add data to existing content or to programmatically create new pages, posts, and the like. Generators run after Bridgetown has made an inventory of the existing content, but before the site is rendered out.

{%@ Note do %}
**Tip:** if all you're doing is creating new resources, perhaps based on data from an external API, you'll likely want to use [Resource Builder API](/docs/plugins/external-apis) rather than write a generator. You can also take a look at [hooks](/docs/plugins/hooks) for fine-grained access to Bridgetown's build lifecycle.
{% end %}

## Builder API

Simply add a `generator` call to your `build` method. You can supply a block or pass in a method name as a symbol.

```ruby
def build
  generator do
    # update or add content here
  end

  generator :build_search_index
end

def build_search_index
  # do some search index building :)
end
```

A generator can inject values computed at build time into page variables. In the
following example, the page `reading.html` will have two variables `ongoing` and `done`
that get added via the generator:

```ruby
class Builders::BookStatus < SiteBuilder
  def build
    generator do
      book_status = remote_data # perhaps fetching data from an API

      reading = site.collections.pages.resources.detect {|page| page.relative_path.basename.to_s == 'reading.html'}
      reading.data['ongoing'] = book_status.ongoing
      reading.data['done'] = book_status.done
    end
  end
end
```
