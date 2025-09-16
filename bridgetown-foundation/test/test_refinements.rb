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

      assert_equal 15, Bridgetown.refine(10).add(5)
    end

    it "supports refine helper mixin" do
      assert_equal({ arr: [1, 2, 3] }, IncludeRefinementsMixin.new.test_dup({ arr: [1, 2, 3] }))
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
      assert (2..5).within?(1..6)
      refute (1..5).within?(2..6)
    end

    it "works with modules" do
      assert Integer.within? Numeric
      refute StringIO.within? String
    end
  end
end
