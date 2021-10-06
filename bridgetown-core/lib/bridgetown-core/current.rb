# frozen_string_literal: true

module Bridgetown
  class Current < ActiveSupport::CurrentAttributes
    # @!method self.site
    #   @return [Bridgetown::Site]

    attribute :site

    # @!method self.preloaded_configuration
    #   @return [Bridgetown::Configuration]
    attribute :preloaded_configuration
  end
end
