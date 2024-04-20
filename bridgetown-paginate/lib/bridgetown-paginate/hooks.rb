# frozen_string_literal: true

# Handles Generated Pages
Bridgetown::Hooks.register_one :generated_pages, :post_init, reloadable: false do |page|
  if page.class != Bridgetown::Paginate::PaginationPage &&
      page.site.config.dig("pagination", "enabled") && (
        page.data.dig(:pagination, :enabled) != false ||
        page.data.dig(:paginate, :enabled) != false
      )
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end

# Handles Resources
Bridgetown::Hooks.register_one :resources, :post_read, reloadable: false do |page|
  if page.site.config.dig("pagination", "enabled") && (
      page.data.dig(:pagination, :enabled) != false ||
      page.data.dig(:paginate, :enabled) != false
    )
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end

# Ensure sites clear out templates before rebuild
Bridgetown::Hooks.register_one :site, :after_reset, reloadable: false do |_site|
  Bridgetown::Paginate::PaginationGenerator.matching_templates.clear
end
