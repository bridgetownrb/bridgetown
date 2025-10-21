###ruby
front_matter do
  layout :default
  custom_var 123
end
###

render html->{ <<~HTML
  <h1>#{text->{ resource.data.title }}</h1>
HTML
}

render { yield }

render html->{ <<~HTML
  <aside>Custom var: #{text->{ layout.data.custom_var }}
HTML
}
