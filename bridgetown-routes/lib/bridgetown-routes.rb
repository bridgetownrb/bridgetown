# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

require_relative "roda/plugins/bridgetown_routes"

require_relative "bridgetown-routes/helpers"

module Bridgetown
  module Routes
    autoload :CodeBlocks, "bridgetown-routes/code_blocks"
    autoload :Manifest, "bridgetown-routes/manifest"
    autoload :RodaRouter, "bridgetown-routes/roda_router"
  end
end
