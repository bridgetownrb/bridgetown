# frozen_string_literal: true

require "minitest_helper"

class TestAnsi < Bridgetown::Foundation::Test
  include Inclusive

  packages def ansi = [Bridgetown::Foundation::Packages::Ansi]

  describe "colors methods" do
    Bridgetown::Foundation::Packages::Ansi.colors.each_key do |color|
      it "responds to color: #{color}" do
        assert ansi.respond_to?(color)
      end
    end
  end

  it "outputs red string" do
    expect("red".red) == "\e[31mred\e[0m"
  end

  describe "color helpers" do
    it "can strip color" do
      expect(ansi.strip(ansi.yellow(ansi.red("hello")))) == "hello"
    end

    it "is able to detect color" do
      expect(ansi.has?("hello".cyan)).true?
    end

    it "will reset color" do
      expect("reset".reset_ansi) == "\e[0mreset"
    end
  end
end
