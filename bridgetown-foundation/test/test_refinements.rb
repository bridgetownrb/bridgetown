# frozen_string_literal: true

require "minitest_helper"

class IncludeRefinementsMixin
  include Bridgetown::Refinements::Helper

  def test_dup(hsh)
    refine(hsh).deep_dup
  end
end

class TestRefinements < Bridgetown::Foundation::Test
  describe "add_refinement" do
    it "supports monkey-patch with refine method" do
      assert_raises NoMethodError do
        Bridgetown.refine(10).add 5
      end

      require_relative "include_refinement"

      expect(Bridgetown.refine(10).add(5)) == 15
    end

    it "supports refine helper mixin" do
      expect(
        IncludeRefinementsMixin.new.test_dup({ arr: [1, 2, 3] })
      ) == { arr: [1, 2, 3] }
    end

    it "uses internal refinements for within?" do
      expect("abc").within? %w[def abc]
    end
  end

  using Bridgetown::Refinements

  describe "within?" do
    it "works with strings" do
      assert "abc".within? %w[def abc]
      refute "abc".within? ["def"]
    end

    it "works with arrays" do
      assert %w[abc xyz].within? %w[xyz def abc]
      refute %w[abc xyz].within? %w[def abc]
    end

    it "works with hashes" do
      assert({ easy_as: 123 }.within?({ indeed: "it's true", easy_as: 123 }))
      refute({ easy_as: 123 }.within?({ indeed: "it's true", easy_as: 456 }))
    end

    it "works with ranges" do
      expect(2..5).within?(1..5)
      expect(1..5).not_within?(2..6)
    end

    it "works with modules" do
      expect(Integer).within? Numeric
      expect(StringIO).not_within? String
    end
  end
end
