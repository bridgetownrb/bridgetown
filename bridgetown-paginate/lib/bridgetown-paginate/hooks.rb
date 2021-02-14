# frozen_string_literal: true

# Handles Legacy Pages
Bridgetown::Hooks.register :pages, :post_init, reloadable: false do |page|
  if page.class != Bridgetown::Paginate::PaginationPage &&
      page.site.config.dig("pagination", "enabled") &&
      page.data.dig("pagination", "enabled")
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end

# Handles Resources
Bridgetown::Hooks.register :pages, :post_read, reloadable: false do |page|
  if page.class != Bridgetown::Paginate::PaginationPage &&
      page.site.config.dig("pagination", "enabled") &&
      page.data.dig("pagination", "enabled")
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end
