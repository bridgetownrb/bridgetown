# frozen_string_literal: true

require "zeitwerk"
require "roda"
require "json"
require "roda/plugins/public"

Bridgetown::Current.preloaded_configuration ||= Bridgetown.configuration

require_relative "logger"
require_relative "routes"
require_relative "static_indexes"

module Bridgetown
  module Rack
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
      autoload_server_folder
    rescue Roda::RodaError => e
      if e.message.include?("sessions plugin :secret option")
        raise Bridgetown::Errors::InvalidConfigurationError,
              "The Roda sessions plugin can't find a valid secret. Run `bin/bridgetown secret' " \
              "and put the key in a ENV var you can use to configure the session in the Roda app"
      end

      raise e
    end

    # @param root [String] root of Bridgetown site, defaults to config value
    def self.autoload_server_folder( # rubocop:todo Metrics
      root: Bridgetown::Current.preloaded_configuration.root_dir
    )
      server_folder = File.join(root, "server")

      Bridgetown::Hooks.register_one(
        :loader, :post_setup, reloadable: false
      ) do |loader, load_path|
        next unless load_path == server_folder

        loader.eager_load
        loader.do_not_eager_load(File.join(server_folder, "roda_app.rb"))

        unless ENV["BRIDGETOWN_ENV"] == "production"
          Listen.to(server_folder) do |modified, added, removed|
            c = modified + added + removed
            n = c.length

            Bridgetown.logger.info(
              "Reloading…",
              "#{n} file#{"s" if n > 1} changed at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
            )
            c.each do |path|
              Bridgetown.logger.info "", "- #{path["#{File.dirname(server_folder)}/".length..]}"
            end

            loader.reload
            loader.eager_load
            Bridgetown::Rack::Routes.reload_subclasses
          rescue SyntaxError => e
            Bridgetown::Errors.print_build_error(e)
          end.start
        end
      end

      Bridgetown::Hooks.register_one(
        :loader, :post_reload, reloadable: false
      ) do |loader, load_path|
        next unless load_path == server_folder

        loader.eager_load
        Bridgetown::Rack::Routes.reload_subclasses
      end

      loaders_manager.setup_loaders([server_folder])
    end
  end
end
