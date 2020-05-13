---
title: HTTP Requests and the Document Builder
hide_in_toc: true
order: 0
category: plugins
---

_docs coming…_

Example:

```ruby
class LoadPostsFromAPI < SiteBuilder
  def build
    get "https://domain.com/posts.json" do |data|
      data.each do |post|
        doc "#{post[:slug]}.md" do
          front_matter post
          categories post[:taxonomy][:category].map { |category| category[:slug] }
          date Bridgetown::Utils.parse_date(post.date)
          content data.body
        end
      end
    end
  end
end
```