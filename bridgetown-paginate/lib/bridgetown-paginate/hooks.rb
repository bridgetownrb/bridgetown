# frozen_string_literal: true

Bridgetown::Hooks.register :pages, :post_init do |page|
  if page.class != Bridgetown::Paginate::PaginationPage &&
      page.site.config.dig("pagination", "enabled") &&
      page.data.dig("pagination", "enabled")
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end
