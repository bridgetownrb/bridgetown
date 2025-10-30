# frozen_string_literal: true

require_relative "../../bridgetown-core/test/helper.rb"
require_relative "../lib/bridgetown-builder.rb"

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new(
    color: true
  ),
]

Bridgetown::Builder # fix autoload weirdness when running certain tests
