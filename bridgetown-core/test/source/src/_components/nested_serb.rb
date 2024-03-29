# frozen_string_literal: true

class NestedSerb < Bridgetown::Component
  def initialize(level:)
    @level = level
    @site = Bridgetown::Current.site
  end

  def render?
    @level < 5
  end
end
