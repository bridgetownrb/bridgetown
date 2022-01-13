class Note < Bridgetown::Component
  def initialize(type: :primary, icon: nil)
    @type, @icon = type.to_sym, icon
  end

  def icon
    return @icon if @icon

    case @type
    when :primary
      "system/information"
    when :warning
      "system/alert"
    end
  end
end