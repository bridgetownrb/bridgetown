require "bridgetown-core/rack/roda"

class RodaApp < Bridgetown::Rack::Roda
  route do |r|
    bridgetown_setup(r)

    if defined?(RodaRoutes)
      RodaRoutes.draw(r)
    end
  end
end
