# frozen_string_literal: true

require "zeitwerk"
require "roda"
require "json"
require "roda/plugins/public"

require_relative "logger"
require_relative "roda"
require_relative "routes"
require_relative "static_indexes"

module Bridgetown
  module Rack
    def self.boot
      Roda.opts[:bridgetown_preloaded_config] = Bridgetown::Current.preloaded_configuration ||
        Bridgetown.configuration
      Roda.opts[:public_root] = Roda.opts[:bridgetown_preloaded_config].destination
      Bridgetown::Site.autoload_config_folder(root: Dir.pwd)
    end
  end
end
