# frozen_string_literal: true

module Bridgetown
  module Rack
    module LoaderHooks
      # Sets up a Zeitwerk loader for the Roda routes in the server folder. Called by the server
      # boot process when Rack starts up
      #
      # @param server_folder [String] typically `server` within the site root
      def self.autoload_server_folder(server_folder)
        reload_file_path = Bridgetown.live_reload_path

        register_hooks server_folder, reload_file_path

        Bridgetown::Rack.loaders_manager.setup_loaders([server_folder])
      end

      # Registers a `post_setup` and `post_reload` hook for the Zeitwerk loader in order to handle
      # eager loading and, in development, the live reload watcher
      #
      # @param server_folder [String]
      # @param reload_file_path [String] path to the special live reload txt file
      def self.register_hooks(server_folder, reload_file_path) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
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
          Bridgetown.touch_live_reload_file(reload_file_path)
        end
      end

      # Creates a listener to detect file changes within the server folder and notify Zeitwerk
      #
      # @param loader [Zeitwerk::Loader]
      # @param server_loader [String]
      # @param subclass_paths [Array<string>]
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
end
