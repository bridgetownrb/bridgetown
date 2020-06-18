# frozen_string_literal: true

unless Bridgetown.environment == "development"
  Bridgetown::Hooks.register :site, :post_write do
    # Load test suite to run on exit
    require "nokogiri"
    Dir["test/**/*.rb"].each { |file| require_relative("../#{file}") }
  rescue LoadError
    Bridgetown.logger.warn "Testing:", "To run tests, you must first run `bundle install --with test`"
  end
end
