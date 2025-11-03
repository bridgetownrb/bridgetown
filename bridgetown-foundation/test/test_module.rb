# frozen_string_literal: true

require "minitest_helper"

class TestModule < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  describe "nesting methods" do
    it "nested_within?" do
      assert Bridgetown::Foundation::CoreExt::String.nested_within? Bridgetown
      assert Bridgetown::Foundation::CoreExt::String.nested_within? Bridgetown::Foundation
      assert Bridgetown::Foundation::CoreExt::String.nested_within? Bridgetown::Foundation::CoreExt
      refute Bridgetown::Foundation::CoreExt::String.nested_within? Bridgetown::Foundation::CoreExt::String
      refute Bridgetown::Foundation::CoreExt.nested_within? Bridgetown::Foundation::CoreExt::String
      refute Bridgetown::Foundation::CoreExt::String.nested_within? Bridgetown::Foundation::RefineExt
    end

    it "nested_parent" do
      expect(Bridgetown::Foundation::CoreExt::String.nested_parent) == Bridgetown::Foundation::CoreExt
    end

    it "nested_name" do
      expect(Bridgetown::Foundation::CoreExt.nested_name) == "CoreExt"
      expect(Bridgetown::Foundation::CoreExt.nested_parent.nested_name) == "Foundation"
    end
  end
end
