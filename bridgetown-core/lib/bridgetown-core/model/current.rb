# frozen_string_literal: true

module Bridgetown
  module Model
    class Current < ActiveSupport::CurrentAttributes
      # @!method self.site
      #   @return [Bridgetown::Site]

      attribute :site
    end
  end
end
