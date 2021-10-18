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
    rescue Roda::RodaError => e
      if e.message.include?("sessions plugin :secret option")
        raise Bridgetown::Errors::InvalidConfigurationError,
              "The Roda sessions plugin can't find a valid secret. Run `bin/bridgetown secret'" \
              " and put the key in a ENV var you can use to configure the session in `roda_app.rb'"
      end

      raise e
    end

    def self.autoload_server_folder(root:)
      server_folder = File.join(root, "server")
      loader = Zeitwerk::Loader.new
      loader.push_dir server_folder
      loader.enable_reloading unless ENV["BRIDGETOWN_ENV"] == "production"
      loader.setup
      loader.eager_load
      loader.do_not_eager_load(File.join(server_folder, "roda_app.rb"))

      unless ENV["BRIDGETOWN_ENV"] == "production"
        begin
          Listen.to(server_folder) do |_modified, _added, _removed|
            loader.reload
            loader.eager_load
            Bridgetown::Rack::Routes.reload_subclasses
          end.start
        # interrupt isn't handled well by the listener
        rescue ThreadError # rubocop:disable Lint/SuppressedException
        end
      end
    rescue Zeitwerk::Error
      # We assume if there's an error it's because Zeitwerk already registered this folder,
      # so it's fine to swallow the error
    end
  end
end
