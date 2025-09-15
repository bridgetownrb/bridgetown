# frozen_string_literal: true

require "minitest_helper"

class TestHash < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  it "it can deep duplicate" do
    hsh = { a: [4, 5], b: { c: 3 } }

    new_hsh = hsh.deep_dup

    refute_equal new_hsh[:a].object_id, hsh[:a].object_id
  end
end
