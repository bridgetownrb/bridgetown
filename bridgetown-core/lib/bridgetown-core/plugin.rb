# frozen_string_literal: true

module Bridgetown
  class Plugin
    extend ActiveSupport::DescendantsTracker

    PRIORITIES = {
      low: -10,
      highest: 100,
      lowest: -100,
      normal: 0,
      high: 10,
    }.freeze

    SourceManifest = Struct.new(:origin, :components, :content, :layouts, keyword_init: true)

    # Get or set the priority of this plugin. When called without an
    # argument it returns the priority. When an argument is given, it will
    # set the priority.
    #
    # priority - The Symbol priority (default: nil). Valid options are:
    #            :lowest, :low, :normal, :high, :highest
    #
    # Returns the Symbol priority.
    def self.priority(priority = nil)
      @priority ||= nil
      @priority = priority if priority && PRIORITIES.key?(priority)
      @priority || :normal
    end

    # Spaceship is priority [higher -> lower]
    #
    # other - The class to be compared.
    #
    # Returns -1, 0, 1.
    def self.<=>(other)
      PRIORITIES[other.priority] <=> PRIORITIES[priority]
    end

    # Spaceship is priority [higher -> lower]
    #
    # other - The class to be compared.
    #
    # Returns -1, 0, 1.
    def <=>(other)
      self.class <=> other.class
    end

    # Initialize a new plugin. This should be overridden by the subclass.
    #
    # config - The Hash of configuration options.
    #
    # Returns a new instance.
    def initialize(config = {}) # rubocop:disable Style/RedundantInitialize
      # no-op for default
    end
  end
end
