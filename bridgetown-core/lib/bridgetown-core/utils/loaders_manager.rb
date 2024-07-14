# frozen_string_literal: true

module Bridgetown
  module Utils
    class LoadersManager
      attr_accessor :config

      attr_reader :loaders, :root_dir

      # @param config [Bridgetown::Configuration]
      # @param root_dir [String] root of the current site
      def initialize(config)
        @config = config
        @loaders = {}
        @root_dir = config.root_dir

        FileUtils.rm_f(Bridgetown.build_errors_path)
      end

      def unload_loaders
        return if @loaders.keys.empty?

        @loaders.each_value(&:unload)
        @loaders = {}
      end

      def reloading_enabled?(load_path)
        load_path.start_with?(root_dir) && ENV["BRIDGETOWN_ENV"] != "production"
      end

      def setup_loaders(autoload_paths = []) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        (autoload_paths.presence || config.autoload_paths).each do |load_path|
          if @loaders.key?(load_path)
            raise "Zeitwerk loader already added for `#{load_path}'. Please check your config"
          end

          next unless Dir.exist? load_path

          loader = Zeitwerk::Loader.new
          loader.inflector = config.inflector if config.inflector
          begin
            loader.push_dir(load_path)
          rescue Zeitwerk::Error
            next
          end
          loader.enable_reloading if reloading_enabled?(load_path)
          loader.ignore(File.join(load_path, "**", "*.js.rb"))
          loader.ignore(
            File.join(File.expand_path(config[:islands_dir], config[:source]), "**", "routes")
          )
          config.autoloader_collapsed_paths.each do |collapsed_path|
            next unless collapsed_path.starts_with?(load_path)

            loader.collapse(collapsed_path)
          end
          Bridgetown::Hooks.trigger :loader, :pre_setup, loader, load_path
          loader.setup
          loader.eager_load if config.eager_load_paths.include?(load_path)
          Bridgetown::Hooks.trigger :loader, :post_setup, loader, load_path
          @loaders[load_path] = loader
        end
      end

      def reload_loaders
        FileUtils.rm_f(Bridgetown.build_errors_path)

        @loaders.each do |load_path, loader|
          next unless reloading_enabled?(load_path)

          Bridgetown::Hooks.trigger :loader, :pre_reload, loader, load_path
          loader.reload
          loader.eager_load if config.eager_load_paths.include?(load_path)
          Bridgetown::Hooks.trigger :loader, :post_reload, loader, load_path
        end
      end
    end
  end
end
