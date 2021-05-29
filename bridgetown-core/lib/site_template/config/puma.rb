# Puma is a fast, concurrent web server for Ruby & Rack
#
# Learn more at: https://puma.io

port 4001

if ENV["BRIDGETOWN_ENV"] == "production"
  workers 3
end
threads 8, 8

preload_app!

require "bridgetown-core/rack/logger"
log_formatter do |msg|
  Bridgetown::Rack::Logger.message_with_prefix msg
end
