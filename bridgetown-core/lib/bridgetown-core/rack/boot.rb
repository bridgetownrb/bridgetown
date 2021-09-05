# frozen_string_literal: true

require "zeitwerk"
require "listen"
require "roda"
require "json"
require "roda/plugins/public"

require_relative "static_indexes"
require_relative "roda"
require_relative "routes"

module Bridgetown
  module Rack
    def self.boot
      Roda.opts[:bridgetown_preloaded_config] = Bridgetown::Current.preloaded_configuration ||
        Bridgetown.configuration
      Roda.opts[:public_root] = Roda.opts[:bridgetown_preloaded_config].destination

      loader = Zeitwerk::Loader.new
      loader.push_dir(File.join(Dir.pwd, "config"))
      loader.enable_reloading unless ENV["BRIDGETOWN_ENV"] == "production"
      loader.setup

      unless ENV["BRIDGETOWN_ENV"] == "production"
        begin
          listener = Listen.to(File.join(Dir.pwd, "config")) do |_modified, _added, _removed|
            loader.reload
          end
          listener.start
        # interrupt isn't handled well by the listener
        rescue ThreadError # rubocop:disable Lint/SuppressedException
        end
      end
    end
  end
end
