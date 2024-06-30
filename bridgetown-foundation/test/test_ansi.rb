# frozen_string_literal: true

require "test_helper"

class TestAnsi < Minitest::Test
  include Inclusive

  packages def ansi = [Bridgetown::Foundation::Packages::Ansi]

  Bridgetown::Foundation::Packages::Ansi.colors.each_key do |color|
    define_method :"test_respond_to_color_#{color}" do
      assert ansi.respond_to?(color)
    end
  end

  def test_string_color_output
    assert_equal "\e[31mred\e[0m", "red".red
  end

  def test_able_to_strip_colors
    assert_equal "hello", ansi.strip(ansi.yellow(ansi.red("hello")))
  end

  def test_able_to_detect_colors
    assert ansi.has?("hello".cyan)
  end

  def test_able_to_reset
    assert "reset", "reset".reset_ansi
  end
end
