class Note < Bridgetown::Component
  def initialize(type: :primary, icon: nil)
    @type, @icon = type.to_sym, icon
  end

  # map from old Shoelace to new Web Awesome
  def type
    case @type
    when :primary
      :success
    else
      @type
    end
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