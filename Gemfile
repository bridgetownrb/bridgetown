# frozen_string_literal: true

source "https://rubygems.org"

gem "rake", "~> 13.0"

group :development do
  gem "launchy", "~> 2.3"
  gem "solargraph"
end

#

group :test do
  gem "cucumber", "~> 3.0"
  gem "jekyll_test_plugin"
  gem "jekyll_test_plugin_malicious"
  gem "memory_profiler"
  gem "minitest"
  gem "minitest-profile"
  gem "minitest-reporters"
  gem "nokogiri", "~> 1.7"
  gem "rspec"
  gem "rspec-mocks"
  gem "rubocop-bridgetown", "~> 0.3.0", require: false
  gem "shoulda"
  gem "simplecov"
end

#

group :bridgetown_optional_dependencies do
  gem "classifier-reborn", "~> 2.2"
  gem "liquid-c", "~> 4.0"
  gem "mime-types", "~> 3.0"
  gem "tomlrb", "~> 1.2"
  gem "yajl-ruby", "~> 1.4"
  gem "yard", "~> 0.9"
end

# Bridgetown
gem "bridgetown", path: "bridgetown"
gem "bridgetown-builder", path: "bridgetown-builder"
gem "bridgetown-core", path: "bridgetown-core"
gem "bridgetown-paginate", path: "bridgetown-paginate"
