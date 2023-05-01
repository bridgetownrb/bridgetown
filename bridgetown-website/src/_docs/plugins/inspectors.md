---
title: HTML and XML Inspectors
order: 0
top_section: Configuration
category: plugins
---

The Inspectors API provides a useful way to review or manipulate the output of your HTML or XML resources. It allows for a safer approach of modifying HTML/XML content than alternatives such as string manipulation or regular expressions which can be prone to error or fail on unexpected input.

The API utilizes [Nokogiri](https://nokogiri.org) or [Nokolexbor](https://github.com/serpapi/nokolexbor), Ruby gems which lets you work with a DOM-like API directly on the nodes of a document tree. Nokogiri supports both HTML & XML files, whereas Nokolexbor only supports HTML (but is noticeably faster with most CSS-style querying).

Bridgetown doesn't directly install the Nokogiri or Nokolexbor gems, so if that isn't already part of your bundle, be sure to update your `Gemfile` to uncomment your gem(s) of choice and then run `bundle install`. If using Nokolexbor, be sure to add `html_inspector_parser: nokolexbor` to your [Bridgetown configuration](/docs/configuration).

{%@ Note type: :warning do %}
  Inspectors will only apply to files Bridgetown considers [Resources](/docs/resources). Thus any HTML or XML file in your project lacking front matter won't get processed through your Inspectors. Make sure you add two lines of triple dashes `---` to the top of any file to indicate it's a Resource.
{% end %}

## Your First Inspector

Let's add an oft-requested feature to our site: automatic `target="_blank"` attributes on all outgoing links. It's easy with an HTML Inspector.

We'll create a new builder plugin and use the `inspect_html` method to access the document and update all the relevant links.

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
Note that `query_selector_all` is an alias for Nokogiri/Nokolexbor's `css` method. We also provide `query_selector` as an alias for `at_css`.
{% end %}

In the example above, we loop through all `a` tags, skip the tag if it already has a target or is not a true external link, otherwise we set the target attribute to `_blank`.

Another example of a feature you might want to add is to append "#" links to the ends of headings in your content so that people can copy a permalink to that particular heading. It's easy with this HTML Inspector:

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

{%@ Note do %}
  Inspector blocks support an optional second `resource` argument if you need access to the underlying Resource object.
{% end %}

## Works with XML Too

If you need to work with XML files such as feeds or sitemaps, you can do this as well with the `inspect_xml` method. It works just like `inspect_html`, except that it can optionally take an extension argument (the default is `xml`).

```ruby
inspect_xml do |document, resource|
  # Work on any .xml file, or…
  # Manually check the specific XML format:
  next unless document.root.name == "urlset"

  # Yay, we found a sitemap!
end

inspect_xml "opml" do |document|
  # OPML files are outlines which can contain URLs or other structured text.
  urls = document.query_selector_all("outline[url]").map { _1[:url] }
  # Do something with the list of URLs in the .opml file…
end
```

## Performance Considerations

All resources which result in HTML or XML output (rather than JSON or some other format) will be processed through any defined Inspectors. For greater performance and fidelity, the Nokogiri/Nokolexbor document for a single resource will be the same across all Inspectors (rather than instantiating a new document for each Inspector).

{%@ Note type: :warning do %}
Nokogiri [relies on a C extension](https://nokogiri.org/#guiding-principles_1) which in turn uses `libxml2`. You should see pretty good performance unless the number of resources in your project is quite extensive.

Nokolexbor [utilizes a C-based library called Lexbor](https://github.com/lexbor/lexbor/) which in some benchmarks shows a noticeable improvement over Nokogiri. Nokolexbor may also in some cases provide greater browser-like fidelity of HTML5 document trees as compared to Nokogiri.
{% end %}

If you find yourself needing to bypass Inspectors for certain, large resources to avoid the overhead of using Nokogiri/Nokolexbor, you can set the [front matter](/docs/front-matter) variable `bypass_inspectors: true` to instruct Bridgetown not to parse that resource. To apply this to a whole array of resources, make it a default with [front matter defaults](/docs/content/front-matter-defaults).
