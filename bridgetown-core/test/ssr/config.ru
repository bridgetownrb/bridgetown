require "bridgetown-core/rack/boot"

Bridgetown::Current.preloaded_configuration = Bridgetown::Configuration.from(
  root_dir: __dir__,
  source: File.join(__dir__, "src"),
  destination: File.join(__dir__, "test_output")
)

Bridgetown::Rack.boot

run RodaApp.freeze.app # see server/roda_app.rb
