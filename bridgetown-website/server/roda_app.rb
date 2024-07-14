# Roda is a simple Rack-based framework with a flexible architecture based
# on the concept of a routing tree. Bridgetown uses it for its development
# server, but you can also run it in production for fast, dynamic applications.
#
# Learn more at: http://roda.jeremyevans.net

class RodaApp < Roda
  plugin :bridgetown_server

  route do |r|
    r.bridgetown
  end
end
