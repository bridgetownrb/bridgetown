---
title: HTML Inspectors
order: 0
top_section: Configuration
category: plugins
---

The HTML Inspectors API, added in Bridgetown 1.1, provides a useful and safe way to manipulate the HTML output of your resources. Safe because instead of using string manipulation, regular expressions, and the like—which is prone to error—you'll be working on real node trees. This is thanks to [Nokogiri](https://nokogiri.org), a Ruby gem which lets you work with a DOM-like API directly on HTML documents.

Bridgetown doesn't directly install the Nokogiri gem, so be sure to run `bundle add nokogiri` if it isn't already part of your bundle.

## Your First Inspector

Let's add an oft-requested feature to our site: automatic `target="_blank"` attributes on all outgoing links. It's easy with an HTML inspector.

We'll create a new builder plugin and use the `inspect_html` method to access the Nokogiri document and update all the relevant links.

```ruby
class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("a").each do |anchor|
        next if anchor[:target]

        next unless anchor[:href]&.starts_with?("http") && !anchor[:href]&.include?(site.config.url)

        anchor[:target] = "_blank"
      end
    end
  end
end
```

{%@ Note do %}
Note that `query_selector_all` is an alias for Nokogiri's `css` method. We also provide `query_selector` as an alias for `at_css`.
{% end %}

In the example above, we loop through all `a` tags, skip the tag if it already has a target or is not a true external link, otherwise we set the target attribute to `_blank`.

Another example of a feature you might want to add is to append "#" links to the ends of headings in your content so that people can copy a permalink to that particular heading. It's easy with this HTML inspector:

```ruby
inspect_html do |document|
  document.query_selector_all("article h2[id], article h3[id]").each do |heading|
    heading << document.create_text_node(" ")
    heading << document.create_element(
      "a", "#",
      href: "##{heading[:id]}",
      class: "heading-anchor"
    )
  end
end
```

You can see this in action right on this very page!

## Performance Considerations

All resources which result in HTML output (rather than JSON or some other format) will be procssed through any defined inspectors. For greater performance and fidelity, the Nokogiri document for a single resource will be the same across all inspectors (rather than instantiating a new Nokogiri document for each inspector).

{%@ Note type: :warning do %}
Nokogiri [relies on a C extension](https://nokogiri.org/#guiding-principles_1) which in turn uses `libxml2`, so generally you should see very fast performance unless the number of resources in your project is extremely large.
{% end %}

If you find yourself needing to bypass inspectors for certain, large resources to avoid the overhead of using Nokogiri, you can set the [front matter](/docs/front-matter) variable `bypass_html_inspectors: true` to instruct Nokogiri not to parse that resource. To apply this to a whole array of resources, make it a default with [front matter defaults.](/docs/content/front-matter-defaults)
