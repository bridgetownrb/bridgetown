---
title: Filters
hide_in_toc: true
order: 0
category: plugins
---

Filters are Ruby modules that export their methods to [Liquid](/docs/liquid/).
All methods will have to take at least one parameter which represents the input
of the filter. The return value will be the output of the filter.

Example:

```ruby
module MySite
  module UrlFilters
    def cache_busting_url(input)
      "http://www.example.com/#{input}?#{Time.now.to_i}"
    end
  end
end

Liquid::Template.register_filter(MySite::UrlFilters)
```

```liquid
{% raw %}{{ "mydynamicfile.js" | cache_busting_url }}{% endraw %}
```

outputs:

```
http://www.example.com/mydynamicfile.js?1586194585
```

<div class="note">
  <h5>Top Tip: Access the site object using Liquid</h5>
  <p>
    Bridgetown lets you access the <code>site</code> object through the
    <code>@context.registers</code> feature of Liquid at <code>@context.registers[:site]</code>. For example, you can
    access the global configuration file <code>bridgetown.config.yml</code> using
    <code>@context.registers[:site].config</code>.
  </p>
</div>
