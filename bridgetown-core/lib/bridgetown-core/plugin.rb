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

    SourceManifest = Struct.new(:origin, :components, :content, :layouts, keyword_init: true)

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
