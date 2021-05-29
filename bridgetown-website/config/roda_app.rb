require "bridgetown-core/rack/roda"
require "bridgetown-core/rack/routes"

class RodaApp < Bridgetown::Rack::Roda
  route do
    if defined?(RodaRoutes)
      RodaRoutes.merge self
    end
  end
end
