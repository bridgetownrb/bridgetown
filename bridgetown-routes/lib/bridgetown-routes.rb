# frozen_string_literal: true

require "bridgetown-core"

module Bridgetown
  module Routes
    autoload :CodeBlocks, "bridgetown-routes/code_blocks"
    autoload :Manifest, "bridgetown-routes/manifest"
    autoload :RodaRouter, "bridgetown-routes/roda_router"
  end
end

# @param config [Bridgetown::Configuration::ConfigurationDSL]
Bridgetown.initializer :"bridgetown-routes" do |
  config,
  additional_source_paths: [],
  additional_extensions: []
|
  config.init :ssr # ensure we already have touchdown!

  config.routes ||= {}
  config.routes.source_paths ||= ["_routes"]
  config.routes.extensions ||= %w(rb md serb erb liquid)

  config.routes.source_paths += Array(additional_source_paths)
  config.routes.extensions += Array(additional_extensions)

  config.only :server do
    require_relative "bridgetown-routes/manifest_router"
  end

  config.roda do |app|
    app.plugin :bridgetown_routes
  end

  require_relative "bridgetown-routes/view_helpers"

  config.builder :BridgetownRoutesBuilder do
    def build
      define_resource_method :roda_app do
        @roda_app
      end

      define_resource_method :roda_app= do |app|
        @roda_app = app
      end
    end
  end
end
