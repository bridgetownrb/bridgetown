# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bridgetown-foundation"

ENV["MT_NO_EXPECTATIONS"] = "true"
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new(
    color: true
  ),
]

require "stringio"

Bridgetown::Foundation::IntuitiveExpectations.enrich Minitest

Minitest::Spec::DSL::InstanceMethods.class_eval do
  # @!method expect
  #   Takes a value
  #   @return [Minitest::Expectation]
end

Minitest::Expectation.class_eval do
  # @!parse include Bridgetown::Foundation::IntuitiveExpectations
end

class Bridgetown::Foundation::Test < Minitest::Test
  # @!parse extend Minitest::Spec::DSL::InstanceMethods

  extend Minitest::Spec::DSL
end
