# frozen_string_literal: true

require "logger"
require "bridgetown-core/log_writer"

module Bridgetown
  module Rack
    class Logger < Bridgetown::LogWriter
      def self.message_with_prefix(msg)
        #        return if msg.include?("/_bridgetown/live_reload")

        "\e[35m[Server]\e[0m #{msg}"
      end

      def enable_prefix
        @formatter = proc do |_, _, _, msg|
          self.class.message_with_prefix(msg)
        end
      end

      def add(severity, message = nil, progname = nil)
        return if progname&.include?("/_bridgetown/live_reload")

        super
      end

      def initialize(*_args)
        super()
        enable_prefix
      end
    end
  end
end
