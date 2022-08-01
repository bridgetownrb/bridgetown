# frozen_string_literal: true

module Bridgetown
  class Plugin
    extend ActiveSupport::DescendantsTracker
    include Bridgetown::Prioritizable

    self.priorities = {
      highest: 100,
      high: 10,
      normal: 0,
      low: -10,
      lowest: -100,
    }.freeze

    # Initialize a new plugin. This should be overridden by the subclass (generator or converter)
    #
    # @param config [Bridgetown::Configuration] the configuration for the site
    def initialize(config = {}) # rubocop:disable Style/RedundantInitialize
      # no-op for default
    end
  end
end
