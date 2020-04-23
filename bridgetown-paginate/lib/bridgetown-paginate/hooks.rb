# frozen_string_literal: true

Bridgetown::Hooks.register :pages, :post_init do |page|
  p Bridgetown::Paginate
  if page.site.config.dig("pagination", "enabled") && page.data.dig("pagination", "enabled")
    Bridgetown::Paginate::PaginationGenerator.add_matching_template(page)
  end
end
