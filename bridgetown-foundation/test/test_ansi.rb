# frozen_string_literal: true

require "test_helper"

class TestAnsi < Minitest::Test
  def setup
    @subject = Bridgetown::Foundation::Ansi
  end

  Bridgetown::Foundation::Ansi::COLORS.each_key do |color|
    define_method :"test_respond_to_color_#{color}" do
      assert @subject.respond_to?(color)
    end
  end

  def test_able_to_strip_colors
    assert_equal "hello", @subject.strip(@subject.yellow(@subject.red("hello")))
  end

  def test_able_to_detect_colors
    assert @subject.has?(@subject.yellow("hello"))
  end
end
