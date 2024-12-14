# frozen_string_literal: true

Bridgetown.configuration(
  root_dir: __dir__,
  destination: "test_output"
)

require "bridgetown-core/utils/initializers"
require "bridgetown-core/rack/boot"

Bridgetown::Rack.boot

require_relative "src/_components/page_me" # normally Zeitwerk would take care of this for us
require_relative "src/_components/use_roda" # normally Zeitwerk would take care of this for us

run RodaApp.freeze.app # see server/roda_app.rb
