---
order: 2503
title: 'Cookbook: Helpers Example'
#top_section: Introduction
category: cookbook
#next_page_order: 30
---

### plugins/builders/helpers.rb
```
class Builders::Helpers < SiteBuilder
  def build
    helper :cache_busting_url do |path|
      "#{Bridgetown::Current.site.config.url}/#{path}?#{Time.now.to_i}"
    end
    helper :multiply_and_optionally_add do |input, multiply_by, add_by = nil|
      value = input * multiply_by
      add_by ? value + add_by : value
    end
  end
end

```
### config/initializers.rb
```
Bridgetown.configure do |config|
# ...
  if Bridgetown.env.production?
    url 'https://bridgtownrb.org'
  end

  if Bridgetown.env.development?
    url 'http://localhost:4000'
    unpublished true
    future true
  end

  if Bridgetown.env.stage?
    url https://stage.bridgtownrb.org'
  end
# ...
end
```