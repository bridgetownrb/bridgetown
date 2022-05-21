# frozen_string_literal: true

module Bridgetown
  module Prioritizable
    module ClassMethods
      # @!method priorities
      #   @return [Hash<Symbol, Object>]

      # Get or set the priority of this class. When called without an
      # argument it returns the priority. When an argument is given, it will
      # set the priority.
      #
      # @param priority [Symbol] new priority (optional)
      #   Valid options are: `:lowest`, `:low`, `:normal`, `:high`, `:highest`
      # @return [Symbol]
      def priority(priority = nil)
        @priority ||= nil
        @priority = priority if priority && priorities.key?(priority)
        @priority || :normal
      end

      # Spaceship is priority [higher -> lower]
      #
      # @param other [Class] The class to be compared.
      # @return [Integer] -1, 0, 1.
      def <=>(other)
        priorities[other.priority] <=> priorities[priority]
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.class_attribute :priorities, instance_accessor: false
    end

    # Spaceship is priority [higher -> lower]
    #
    # @param other [object] The object to be compared.
    # @return [Integer] -1, 0, 1.
    def <=>(other)
      self.class <=> other.class
    end
  end
end
