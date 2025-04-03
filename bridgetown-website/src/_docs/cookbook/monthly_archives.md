---
order: 2502
title: 'Cookbook: Monthly Archive'
#top_section: Introduction
category: cookbook
#next_page_order: 30
---
### plugins/builders/monthly_archives.rb

```ruby
class Builders::MonthlyArchives < SiteBuilder
  using Bridgetown::Refinements

  priority :high

  COLLECTIONS = %w(posts)

  def build
    hook :resources, :post_read do |resource|
      add_monthly_data(resource) if resource.collection.label.within?(COLLECTIONS)
    end

    helper :monthly_archive_list do
      site.data
        .monthly_archives
        .map { _1.split("|") } # split 2010-05|May 2010
        .sort_by { _1[0] }
        .map { _1[1] }
        .reverse
    end
  end

  def add_monthly_data(resource)
    resource.data.monthly = resource.date.strftime("%B %Y") # May 2010
    site.data.monthly_archives ||= Set.new
    site.data.monthly_archives << "#{resource.date.strftime("%Y-%m")}|#{resource.data.monthly}"
  end
end
```

### your pagination page front matter

```yaml
title: ":prototype-term-titleize Archive"
exclude_from_search: true
prototype:
  collection: posts
  term: monthly
```