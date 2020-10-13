export toggle_menu_icon = ->(button) do
  button.query_selector_all(".icon").each do |item|
    item.class_list.toggle "not-shown"
  end
  button.query_selector(".icon:not(.not-shown)").class_list.add("shown")
end

export add_heading_anchors = ->() do
  if document.body.class_list.contains? "docs"
    document.query_selector_all(".content h2[id], .content h3[id]").each do |heading|
      anchor_link = document.create_element("a")
      anchor_link.inner_text = "#"
      anchor_link.href = "##{heading.id}"
      anchor_link.class_list.add ".heading-anchor".slice(1) # purgecss
      heading.append_child anchor_link
    end
  end
end
