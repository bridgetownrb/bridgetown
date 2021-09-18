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

    # rubocop:disable Bridgetown/NoPutsAllowed
    def self.print_roda_routes
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
        puts [route["methods"]&.join("|") || "GET", route["path"]].compact.join(" ")
      end
    end
    # rubocop:enable Bridgetown/NoPutsAllowed
  end
end
