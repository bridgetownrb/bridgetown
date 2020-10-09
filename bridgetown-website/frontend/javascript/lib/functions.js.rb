export toggle_menu_icon = ->(button) do
  button.query_selector_all(".icon").each do |item|
    item.class_list.toggle "not-shown"
  end
  button.query_selector(".icon:not(.not-shown)").class_list.add("shown")
end

export add_heading_anchors = ->() do
  if document.body.class_list.contains("docs")
    document.query_selector_all(".content h2[id], .content h3[id]").each do |heading|
      anchorLink = document.create_element("a")
      anchorLink.inner_text = "#"
      anchorLink.href = "#" + heading.id
      anchorLink.class_list.add "heading-anchor"
      heading.append_child anchorLink
    end
  end
end


