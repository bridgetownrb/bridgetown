# frozen_string_literal: true

module Bridgetown
  module Deprecator
    def self.deprecation_message(message)
      Bridgetown.logger.warn "Deprecation:", message

      caller_locations[0..1].each_with_index do |backtrace_line, index|
        Bridgetown.logger.debug "#{index + 1}:", backtrace_line
      end
    end
  end
end
