# frozen_string_literal: true

require "logger"

module Bridgetown
  module Rack
    class Logger < Logger
      def self.message_with_prefix(msg)
        return if msg.include?("/_bridgetown/live_reload")

        "\e[35m[Server]\e[0m #{msg}"
      end

      def initialize(*)
        super
        @formatter = proc do |_, _, _, msg|
          self.class.message_with_prefix(msg)
        end
      end
    end
  end
end
