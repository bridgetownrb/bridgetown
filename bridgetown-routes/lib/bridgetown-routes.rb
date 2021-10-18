# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

require_relative "roda/plugins/bridgetown_routes"
require_relative "bridgetown-routes/view_helpers"

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

module Bridgetown
  module Routes
    module FlashHashAdditions
      def info
        self["info"]
      end

      def info=(val)
        self["info"] = val
      end

      def alert
        self["alert"]
      end

      def alert=(val)
        self["alert"] = val
      end
    end
  end
end

Roda::RodaPlugins::Flash::FlashHash.include Bridgetown::Routes::FlashHashAdditions
Roda::RodaPlugins::Flash::FlashHash.class_eval do
  def initialize(hash = {})
    super(hash || {})
    now.singleton_class.include Bridgetown::Routes::FlashHashAdditions
    @next = {}
  end
end
