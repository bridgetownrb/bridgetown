# frozen_string_literal: true

Thread.attr_accessor :bridgetown_state

module Bridgetown
  class Current
    class << self
      def thread_state = Thread.current.bridgetown_state ||= {}

      # @return [Bridgetown::Site, nil]
      def site = sites[:main]

      def site=(new_site)
        sites[:main] = new_site
      end

      # @return [Hash<Symbol, Bridgetown::Site>]
      def sites
        thread_state[:sites] ||= {}
      end

      # @return [Bridgetown::Configuration]
      def preloaded_configuration = thread_state[:preloaded_configuration]

      def preloaded_configuration=(value)
        thread_state[:preloaded_configuration] = value
      end
    end
  end
end
