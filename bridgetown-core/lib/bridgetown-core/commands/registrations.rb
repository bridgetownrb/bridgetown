# frozen_string_literal: true

module Bridgetown
  module Commands
    module Registrations
      def self.registrations
        @registrations ||= []
      end

      def self.register(klass = nil, name = nil, &block)
        block ||= proc { register(klass, name) }

        registrations << block
      end

      def self.load_registrations(command)
        registrations.each do |block|
          command.instance_exec(&block)
        end
      end
    end
  end
end
