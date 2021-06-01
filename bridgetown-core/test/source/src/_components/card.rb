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

  # poor man's slot
  def image(&block)
    if block
      @_image_content = view_context.capture(&block)
      nil
    else
      content # make sure content block is first evaluated
      @_image_content
    end
  end
end
