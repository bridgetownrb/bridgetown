require "bridgetown-core/rack/roda"
require "bridgetown-core/rack/routes"

# Roda is a simple Rack-based framework with a flexible architecture based
# on the concept of a routing tree. Bridgetown uses it for its development
# server, but you can also run it in production for fast, dynamic applications.
#
# Learn more at: http://roda.jeremyevans.net

class RodaApp < Bridgetown::Rack::Roda
  route do
    if defined?(RodaRoutes) # see config/roda_routes.rb.sample
      RodaRoutes.merge self
    end
  end
end
