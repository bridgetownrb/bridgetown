# frozen_string_literal: true

class Nested < Bridgetown::Component
  def initialize(level:)
    @level = level
  end

  def render?
    @level < 5
  end
end
