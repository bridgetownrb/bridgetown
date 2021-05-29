require "bridgetown-core/rack/boot"

Bridgetown::Rack.boot

run RodaApp.freeze.app
