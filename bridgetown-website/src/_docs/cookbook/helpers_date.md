---
order: 2503
title: 'Cookbook: Date Helpers'
#top_section: Introduction
category: cookbook
#next_page_order: 30
---

### plugins/builders/datehelpers.rb
```
require_relative '../../lib/date_helpers'

class Builders::Datehelpers < SiteBuilder
  def build
    helper :standardize_date do |dt|
      DateHelpers.standardize_date(dt)
    end
    helper :display_date do |dt|
      DateHelpers.standardize_date(dt).strftime('%A %e %B %Y')
    end
  end
end
```
### lib/date_helpers.rb
```
module DateHelpers
  def self.standardize_date(date)
    case date
    when String
      begin
        Date.parse(date)
      rescue ArgumentError
        nil
      end
    when Date, Time, DateTime
      date.to_date
    else
      nil
    end
  end
end
```