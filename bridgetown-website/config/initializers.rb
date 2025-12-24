# frozen_string_literal: true

Bridgetown.configure do |config|
  init :"bridgetown-seo-tag"
  init :"bridgetown-feed"
  init :"bridgetown-quick-search"
  init :"bridgetown-svg-inliner"

  config.inflector.configure do |inflections|
    inflections.acronym "W3C"
  end

  only :server do
    init :parse_routes
  end
end
