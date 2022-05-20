class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("article h2[id], article h3[id]").each do |heading|
        heading << document.create_text_node(" ")
        heading << document.create_element(
          "a", "#",
          href: "##{heading[:id]}",
          class: "heading-anchor"
        )
      end
    end
  end
end
