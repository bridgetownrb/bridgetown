# frozen_string_literal: true

class Card < Bridgetown::Component
  def initialize(title:, footer:)
    @title = title
    @footer = footer
  end

  def before_render
    @upcase_title = @title.upcase
  end

  def kind
    :card
  end

  def render?
    @footer != "CANCEL!"
  end
end
