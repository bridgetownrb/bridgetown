require "bridgetown-core/rack/boot"

Bridgetown::Rack.boot do
  unless ENV["BRIDGETOWN_ENV"] == "production"
    run_process "Webpack", :yellow, "bin/bridgetown frontend:dev"
    run_process "Live", nil, "sleep 7 && yarn sync --color"
  end
end

run RodaApp.freeze.app
