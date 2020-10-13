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
      anchor_ink.inner_text = "#"
      anchor_ink.href = "##{heading.id}"
      anchor_ink.class_list.add ".heading-anchor".slice(1) # purgecss
      heading.append_child anchor_link
    end
  end
end
