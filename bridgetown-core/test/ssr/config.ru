# frozen_string_literal: true

require "bridgetown-core/rack/boot"

Bridgetown::Current.preloaded_configuration = Bridgetown::Configuration.from(
  root_dir: __dir__,
  destination: "test_output"
)

Bridgetown::Rack.boot

run RodaApp.freeze.app # see server/roda_app.rb
