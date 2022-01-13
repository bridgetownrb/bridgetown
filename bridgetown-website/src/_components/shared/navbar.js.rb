def menu_show(toggler)
  bar = document.query_selector("body > nav sl-bar")
  bar.set_attribute "expanded", true
  bar.query_selector_all("sl-bar-item[expandable]").each do|item|
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

document.add_event_listener "turbo:load" do
  search = document.query_selector("bridgetown-search-results")
  search.show_results = false
  search.results = []

  nav = document.query_selector("body > nav")

  nav.query_selector_all("a").each do |item|
    item.class_list.remove :active
  end

  menu_hide nav.query_selector("sl-button[menutoggle]")

  if location.pathname.starts_with?("/docs")
    nav.query_selector('a[href="/docs"]').class_list.add :active
  elsif location.pathname.starts_with?("/plugins")
    nav.query_selector('a[href="/plugins"]').class_list.add :active
  elsif location.pathname.starts_with?("/community")
    nav.query_selector('a[href="/community"]').class_list.add :active
  elsif location.pathname.starts_with?("/blog") || document.body.class_list.contains("post")
    nav.query_selector('a[href="/blog"]').class_list.add :active
  end
end

window.menu_hide = menu_hide
window.menu_show = menu_show
