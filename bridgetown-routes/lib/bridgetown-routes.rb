# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

require_relative "bridgetown-routes/view_helpers"

# Roda isn't defined for Bridgetown build-only
require_relative "roda/plugins/bridgetown_routes" if defined?(Roda)

module Bridgetown
  module Routes
    autoload :CodeBlocks, "bridgetown-routes/code_blocks"
    autoload :Manifest, "bridgetown-routes/manifest"
    autoload :RodaRouter, "bridgetown-routes/roda_router"

    # rubocop:disable Bridgetown/NoPutsAllowed
    def self.print_roda_routes
      # TODO: this needs to be fully documented, currently no info on how to generate .routes.json
      routes = begin
        JSON.parse(File.read("#{Dir.pwd}/.routes.json"))
      rescue StandardError
        []
      end
      puts
      puts "Routes:"
      puts "======="
      if routes.blank?
        puts "No routes found. Have you commented all of your routes?"
        puts "Documentation: https://github.com/jeremyevans/roda-route_list#basic-usage-"
      end

      routes.each do |route|
        puts [route["methods"]&.join("|") || "GET", route["path"], route["file"]].compact.join(" ")
      end
      puts
    end
    # rubocop:enable Bridgetown/NoPutsAllowed
  end
end

module RodaResourceExtension
  module RubyResource
    def roda_app=(app)
      unless app.is_a?(Bridgetown::Rack::Roda)
        raise Bridgetown::Errors::FatalException,
              "Resource's assigned Roda app must be of type `Bridgetown::Rack::Roda'"
      end

      @roda_app = app
    end

    def roda_app
      @roda_app
    end
  end
end
Bridgetown::Resource.register_extension RodaResourceExtension
