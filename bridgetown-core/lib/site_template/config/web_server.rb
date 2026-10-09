# Use this file to configure your development web server.
#
# By default, Bridgetown will automatically detect `puma` or `falcon`
# and run it using its CLI when you run `bin/bt start`. You can use
# this file to customize the options passed to the CLI.
#
# See `bridgetown-core/rack/environments/` for config options.

# server :falcon do
#   port      4000
#   scheme    :https
#   bind      { "#{scheme}://localhost" }
#   options   ["-n", "1"]
# end

# server :puma do
#   port      4000
#   bind      "tcp://0.0.0.0"
#   options   ["-s"]
# end

# An example of a Rack server not officially supported by Bridgetown.
# You need to define the `command` option which will be invoked to start
# the server when you run `bin/bt start`.
#
# server :pitchfork do
#   command "pitchfork"
# end

