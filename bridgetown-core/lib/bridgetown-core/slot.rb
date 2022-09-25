# frozen_string_literal: true

module Bridgetown
  class Slot
    attr_reader :name, :content

    def initialize(name:, content:)
      @name, @content = name, content
    end
  end
end
