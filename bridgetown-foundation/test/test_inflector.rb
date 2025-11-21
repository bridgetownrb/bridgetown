# frozen_string_literal: true

require "minitest_helper"

class TestInflector < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  describe "string inflector methods" do
    it "can #camelize and #camelize_lower" do
      expect("well_hello_world".camelize) == "WellHelloWorld"
      expect("well_hello_world".camelize_lower) == "wellHelloWorld"
    end

    it "can #classify" do
      expect("foo_bar/baz/quux_done".classify) == "FooBar::Baz::QuuxDone"
    end

    it "can #constantize" do
      expect("bridgetown/foundation/questionable_string".classify.constantize) ==
        Bridgetown::Foundation::QuestionableString
    end

    it "can #dasherize" do
      expect("Dash_this-".dasherize) == "Dash-this-"
    end

    it "can #humanize" do
      expect("one_frosty_morning".humanize) == "One frosty morning"
    end

    it "can #pluralize" do
      expect("goat".pluralize) == "goats"
    end

    it "can #singularize" do
      expect("goats".singularize) == "goat"
    end

    it "can #underscore" do
      expect("OHappyDay".underscore) == "o_happy_day"
    end
  end
end
