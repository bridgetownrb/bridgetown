# frozen_string_literal: true

Bridgetown.configure do
  require "bridgetown-routes"
  init :ssr
  init :"bridgetown-routes", require_gem: false

  routes.source_paths << File.expand_path("alt_routes", "#{root_dir}/../")
end
