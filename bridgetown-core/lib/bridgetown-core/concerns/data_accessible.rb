# frozen_string_literal: true

module Bridgetown
  module DataAccessible
    # Returns the contents as a String.
    def to_s
      output || content || ""
    end

    # Accessor for data properties by Liquid.
    #
    # property - The String name of the property to retrieve.
    #
    # Returns the String value or nil if the property isn't included.
    def [](property)
      data[property]
    end
  end
end
