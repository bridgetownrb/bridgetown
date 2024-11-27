# frozen_string_literal: true

require "zeitwerk"
require "roda"
require "json"
require "bridgetown"

require_relative "loader_hooks"
require_relative "logger"
require_relative "routes"

module Bridgetown
  module Rack
    Bridgetown.begin!(with_config: :initializers)

    class << self
      # @return [Bridgetown::Utils::LoadersManager]
      attr_accessor :loaders_manager
    end

    # Start up the Roda Rack application and the Zeitwerk autoloaders. Ensure the
    # Roda app is provided the preloaded Bridgetown site configuration. Handle
    # any uncaught Roda errors.
    def self.boot(*)
      self.loaders_manager =
        Bridgetown::Utils::LoadersManager.new(Bridgetown::Current.preloaded_configuration)
      Bridgetown::Current.preloaded_configuration.run_initializers! context: :server
      LoaderHooks.autoload_server_folder(
        File.join(Bridgetown::Current.preloaded_configuration.root_dir, "server")
      )
    end
  end
end
