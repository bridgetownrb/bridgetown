# frozen_string_literal: true

require "bridgetown-core/rack/boot"

Bridgetown::Rack.boot

unless defined?(RodaApp)
  class RodaApp < Roda
    plugin :bridgetown_server
    route(&:bridgetown)
  end
end

run RodaApp.freeze.app
