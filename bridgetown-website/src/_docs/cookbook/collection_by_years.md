---
order: 2501
title: Cookbook Collection By Years
#top_section: Introduction
category: cookbook
#next_page_order: 30
---

### _components/years.rb

```ruby
class Years < Bridgetown::Component
  def initialize(collection:)
    @archive = []
    current_year = nil
    current_year_data = []

    collection.resources.each do |resource|
      year = resource.date.year
      if year != current_year
        # Save the previous year's data if it exists
        @archive << { year: current_year, pages: current_year_data } if current_year
        # Start a new year
        current_year = year
        current_year_data = [resource]
      else
        current_year_data << resource
      end
    end

    # Don't forget to add the last year's data
    return unless current_year

    @archive << { year: current_year, pages: current_year_data }
  end
end
```

### _components/years.erb

```erb
<!-- If you're not using Bootstrap define the d-none style or
switch to your framework's equivalent class.
<style>
.d-none { display: none; }
</style>
-->
<% classlist = '' %>
<% @archive.each do |yeargroup| %>
  <h2 ><%= yeargroup[:year] %> </h2>
  <div <%= raw classlist %> >
  <% classlist = 'class="d-none"' %>
  <% pages = yeargroup[:pages] %>

  <ul>
  <% pages.each do |page| %>
    <li><%= page.data.date.strftime('%B %e') %>
      <a href="<%= page.relative_url %>"><%= page.data.title %></a></li>
  <% end %>
  </ul>
  </div>
<% end %>

<!-- make sure jquery loads before this script -->
<script>
$(document).ready(function() {
  $('h2').css('cursor', 'pointer');
  $('h2').on('click', function() {
    $('h2').not(this).next('div').addClass('d-none');
    $(this).next('div').removeClass('d-none');
  });
});
</script>
```

### years.md in one of your collections

```erb
---
title: Collection Pages Grouped by Year
# Do not paginate this page.
---
<%= render Years.new(collection: collections.posts ) %>
```
