# frozen_string_literal: true

module Bridgetown
  module Commands
    module Registrations
      def self.registrations
        @registrations || []
      end

      def self.register(&block)
        @registrations ||= []
        @registrations.push(block)
      end
    end
  end
end
