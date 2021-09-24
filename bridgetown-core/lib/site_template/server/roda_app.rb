# Roda is a simple Rack-based framework with a flexible architecture based
# on the concept of a routing tree. Bridgetown uses it for its development
# server, but you can also run it in production for fast, dynamic applications.
#
# Learn more at: http://roda.jeremyevans.net

# Uncomment to use the file-based routing for Bridgetown SSR:
# require "bridgetown-routes"

class RodaApp < Bridgetown::Rack::Roda
  # Add additional Roda configuration here if needed

  # Uncomment to use Bridgetown SSR:
  # plugin :bridgetown_ssr
  # plugin :bridgetown_routes

  route do |r|
    # Load all files in server/routes and src/_routes if "bridgetown-routes" is loaded
    # (see server/routes/hello.rb.sample)
    Bridgetown::Rack::Routes.start! self
  end
end
