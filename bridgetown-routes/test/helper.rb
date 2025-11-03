# frozen_string_literal: true

require_relative "../../bridgetown-core/test/helper"
require "bridgetown-builder"
require "rack"
require "rack/test"

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new(
    color: true
  ),
]

Bridgetown.begin!
