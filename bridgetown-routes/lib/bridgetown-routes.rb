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
Bridgetown.initializer :"bridgetown-routes" do |config|
  config.only :server do
    require_relative "bridgetown-routes/manifest_router"
  end

  require_relative "bridgetown-routes/view_helpers"

  config.builder :BridgetownRoutesBuilder do
    def build
      define_resource_method :roda_app do
        @roda_app
      end

      define_resource_method :roda_app= do |app|
        unless app.is_a?(Bridgetown::Rack::Roda)
          raise Bridgetown::Errors::FatalException,
                "Resource's assigned Roda app must be of type `Bridgetown::Rack::Roda'"
        end

        @roda_app = app
      end
    end
  end
end
