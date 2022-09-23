def menu_show(toggler)
  bar = document.query_selector("body > nav sl-bar")
  bar.set_attribute "expanded", true
  bar.query_selector_all("sl-bar-item[expandable]").each do |item|
    item.class_list.add "fade-in-always"
  end
  toggler.query_selector("sl-icon").name = "system/close"
end

def menu_hide(toggler)
  bar = document.query_selector("body > nav sl-bar")
  bar.set_attribute "expanded", false
  bar.query_selector_all("sl-bar-item[expandable]").each do |item|
    item.class_list.remove "fade-in-always"
  end
  toggler.query_selector("sl-icon").name = "system/menu"
end

def set_current_nav_item(nav, path)
  link = nav.query_selector(%(a[href="#{path}"]))
  link_pathname = URL.new(link.href).pathname

  if link_pathname == location.pathname
    link.set_attribute "aria-current", "page"
  else
    link.set_attribute "aria-current", "true"
  end
end

document.add_event_listener "turbo:load" do
  search = document.query_selector("bridgetown-search-results")
  search.show_results = false
  search.results = []

  nav = document.query_selector("body > nav")

  menu_hide nav.query_selector("sl-button[menutoggle]")

  nav.query_selector_all("a").each do |item|
    item.remove_attribute "aria-current"
  end

  if location.pathname == "/"
    set_current_nav_item nav, "/"
  elsif location.pathname.starts_with?("/docs")
    set_current_nav_item nav, "/docs"
  elsif location.pathname.starts_with?("/plugins")
    set_current_nav_item nav, "/plugins"
  elsif location.pathname.starts_with?("/community")
    set_current_nav_item nav, "/community"
  elsif location.pathname.starts_with?("/blog") || document.body.class_list.contains("post")
    set_current_nav_item nav, "/blog"
  end
end

window.menu_hide = menu_hide
window.menu_show = menu_show
