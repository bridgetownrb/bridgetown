# frozen_string_literal: true

module Bridgetown
  class CollectionReader
    SPECIAL_LEGACY_COLLECTIONS = %w(posts data).freeze

    attr_reader :site, :content

    def initialize(site)
      @site = site
      @content = {}
    end

    # Read in all collections specified in the configuration
    #
    # Returns nothing.
    def read
      site.collections.each_value do |collection|
        collection.read unless site.config.content_engine != "resource" &&
          SPECIAL_LEGACY_COLLECTIONS.include?(collection.label)
      end
    end
  end
end
