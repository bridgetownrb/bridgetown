# frozen_string_literal: true

module Bridgetown
  class Current < ActiveSupport::CurrentAttributes
    # # @!method self.site
    # #   @return [Bridgetown::Site]

    # attribute :site

    # @!method self.preloaded_configuration
    #   @return [Bridgetown::Configuration]
    attribute :preloaded_configuration

    def self.site
      sites[:main]
    end

    def self.site=(new_site)
      sites[:main] = new_site
    end

    # @!method self.sites
    #   @return [Hash<Symbol, Bridgetown::Site>]

    attribute :sites

    def initialize
      super
      @attributes[:sites] = {}
    end
  end
end
