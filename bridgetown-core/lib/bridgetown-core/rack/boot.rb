# frozen_string_literal: true

require "zeitwerk"
require "listen"
require "roda"
require "json"
require "roda/plugins/public"

require_relative "static_indexes"

module Bridgetown
  module Rack
    def self.boot(destination: "output")
      Roda.opts[:public_root] = destination

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
