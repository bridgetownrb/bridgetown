# frozen_string_literal: true

require "minitest/autorun"
require "minitest/reporters"
require "minitest/profile"
require "shoulda"
require "nokogiri"
require "bundler"

# Report with color.
Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(
    color: true
  ),
]

Minitest::Test.class_eval do
  def site
    @site ||= Bridgetown.sites.first
  end

  def nokogiri(input)
    input.respond_to?(:output) ? Nokogiri::HTML(input.output) : input
  end
end
