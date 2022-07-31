# frozen_string_literal: true

module Bridgetown
  module Deprecator
    def self.deprecation_message(message)
      Bridgetown.logger.warn "Deprecation:", message
    end
  end
end
