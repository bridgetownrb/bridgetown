# frozen_string_literal: true

require "zeitwerk"
require "roda"
require "json"

Bridgetown::Current.preloaded_configuration ||= Bridgetown.configuration

require_relative "logger"
require_relative "routes"

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
    def self.autoload_server_folder( # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      root: Bridgetown::Current.preloaded_configuration.root_dir
    )
      server_folder = File.join(root, "server")
      cached_reload_file = Bridgetown.live_reload_path

      Bridgetown::Hooks.register_one(
        :loader, :post_setup, reloadable: false
      ) do |loader, load_path|
        next unless load_path == server_folder

        loader.eager_load
        subclass_names = Roda.subclasses.map(&:name)
        subclass_paths = Set.new

        loader.all_expected_cpaths.each do |cpath, cname|
          if subclass_names.include?(cname) && cpath.start_with?(server_folder)
            subclass_paths << cpath
            loader.do_not_eager_load cpath
          end
        end

        unless ENV["BRIDGETOWN_ENV"] == "production"
          setup_autoload_listener loader, server_folder, subclass_paths
        end
      end

      Bridgetown::Hooks.register_one(
        :loader, :post_reload, reloadable: false
      ) do |loader, load_path|
        next unless load_path == server_folder

        loader.eager_load
        Bridgetown.touch_live_reload_file(cached_reload_file)
      end

      loaders_manager.setup_loaders([server_folder])
    end

    def self.setup_autoload_listener(loader, server_folder, subclass_paths)
      Listen.to(server_folder) do |modified, added, removed|
        c = modified + added + removed
        n = c.length

        unless n == 1 && subclass_paths.include?(c.first)
          Bridgetown.logger.info(
            "Reloading…",
            "#{n} file#{"s" if n > 1} changed at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          )
          c.each do |path|
            Bridgetown.logger.info "", "- #{path["#{File.dirname(server_folder)}/".length..]}"
          end
        end

        loader.reload
        Bridgetown::Hooks.trigger :loader, :post_reload, loader, server_folder
      rescue SyntaxError => e
        Bridgetown::Errors.print_build_error(e)
      end.start
    end
  end
end
