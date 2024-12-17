# frozen_string_literal: true

class Shared::Stuff < Bridgetown::Component
  def initialize(wild:) # rubocop:disable Lint/MissingSuper
    @wild = wild * 2
  end

  def template
    "Well that was #{@wild}!#{content}"
  end
end
