# frozen_string_literal: true

module Bridgetown
  module Utils
    class LoadersManager
      attr_accessor :config

      attr_reader :loaders, :root_dir

      # @param config [Bridgetown::Configuration]
      # @param root_dir [String] root of the current site
      def initialize(config, root_dir = Dir.pwd)
        @config = config
        @loaders = {}
        @root_dir = root_dir
      end

      def unload_loaders
        return if @loaders.keys.empty?

        @loaders.each do |_path, loader|
          loader.unload
        end
        @loaders = {}
      end

      def reloading_enabled?(load_path)
        load_path.start_with?(root_dir) && ENV["BRIDGETOWN_ENV"] != "production"
      end

      def setup_loaders(autoload_paths = [])
        (autoload_paths.presence || config.autoload_paths).each do |load_path|
          if @loaders.key?(load_path)
            raise "Zeitwerk loader already added for `#{load_path}'. Please check your config"
          end

          next unless Dir.exist? load_path

          loader = Zeitwerk::Loader.new
          begin
            loader.push_dir(load_path)
          rescue Zeitwerk::Error
            next
          end
          loader.enable_reloading if reloading_enabled?(load_path)
          loader.ignore(File.join(load_path, "**", "*.js.rb"))
          Bridgetown::Hooks.trigger :loader, :pre_setup, loader, load_path
          loader.setup
          Bridgetown::Hooks.trigger :loader, :post_setup, loader, load_path
          @loaders[load_path] = loader
        end
      end

      def reload_loaders
        @loaders.each do |load_path, loader|
          Bridgetown::Hooks.trigger :loader, :pre_reload, loader, load_path
          loader.reload if reloading_enabled?(load_path)
          Bridgetown::Hooks.trigger :loader, :post_reload, loader, load_path
        end
      end
    end
  end
end
