# frozen_string_literal: true

require "logger"
require "bridgetown-core/log_writer"
require "bridgetown/foundation/packages/ansi"

module Bridgetown
  module Rack
    class Logger < Bridgetown::LogWriter
      PREFIX = "Server"

      def self.message_with_prefix(msg)
        prefix = Bridgetown::Foundation::Packages::Ansi.yellow("[#{PREFIX}]")
        "#{prefix} #{msg}"
      end

      def add(severity, message = nil, progname = nil)
        return if progname&.include?("/_bridgetown/live_reload")

        super
      end

      def initialize(*_args)
        super()
        set_prefix(PREFIX, color: :yellow)
      end
    end
  end
end
