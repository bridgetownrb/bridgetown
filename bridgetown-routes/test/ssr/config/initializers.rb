# frozen_string_literal: true

Bridgetown.configure do |config|
  require "bridgetown-routes"
  init :"bridgetown-routes", require_gem: false

  routes.source_paths << File.expand_path("alt_routes", "#{root_dir}/../")

  config.available_locales = [:en, :it]
  config.default_locale = :en
  config.prefix_default_locale = false
end
