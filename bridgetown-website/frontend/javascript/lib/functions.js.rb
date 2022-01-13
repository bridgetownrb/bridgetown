export def add_heading_anchors()
  document.query_selector_all("article h2[id], article h3[id]").each do |heading|
    anchor_link = document.create_element("a")
    anchor_link.inner_text = "#"
    anchor_link.href = "##{heading.id}"
    anchor_link.class_list.add "heading-anchor"
    heading.append_child anchor_link
  end
end
