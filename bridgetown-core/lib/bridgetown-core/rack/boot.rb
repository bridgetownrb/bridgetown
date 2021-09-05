# frozen_string_literal: true

require "zeitwerk"
require "roda"
require "json"
require "roda/plugins/public"

Bridgetown::Current.preloaded_configuration ||= Bridgetown.configuration

require_relative "logger"
require_relative "roda"
require_relative "routes"
require_relative "static_indexes"

module Bridgetown
  module Rack
    def self.boot
      autoload_server_folder(root: Dir.pwd)
      RodaApp.opts[:bridgetown_preloaded_config] = Bridgetown::Current.preloaded_configuration
    end

    def self.autoload_server_folder(root:)
      server_folder = File.join(root, "server")
      loader = Zeitwerk::Loader.new
      loader.push_dir server_folder
      loader.enable_reloading unless ENV["BRIDGETOWN_ENV"] == "production"
      loader.on_load do |_cpath, value, _abspath|
        if value.ancestors.include?(Bridgetown::Rack::Routes)
          Bridgetown::Rack::Routes.track_subclass value
        end
      end
      loader.setup
      loader.eager_load

      unless ENV["BRIDGETOWN_ENV"] == "production"
        begin
          Listen.to(server_folder) { |_modified, _added, _removed| loader.reload }.start
        # interrupt isn't handled well by the listener
        rescue ThreadError # rubocop:disable Lint/SuppressedException
        end
      end
    rescue Zeitwerk::Error
      # We assume if there's an error it's becuase Zeitwerk already registered this folder,
      # so it's fine to swallow the error
    end
  end
end
