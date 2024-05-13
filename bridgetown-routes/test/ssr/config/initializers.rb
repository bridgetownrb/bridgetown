# frozen_string_literal: true

Bridgetown.configure do |config|
  require "bridgetown-routes"
  init :"bridgetown-routes", require_gem: false, additional_source_paths:
    File.expand_path("alt_routes", "#{root_dir}/..")

  config.available_locales = [:en, :it]
  config.default_locale = :en
  config.prefix_default_locale = false

  # puts foundation(Bridgetown.env.to_sym).within?([:test, :production]) # => true
end
