# frozen_string_literal: true

require "minitest_helper"

class TestHash < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  it "can deep duplicate" do
    hsh = { a: [4, 5], b: { c: 3 } }

    new_hsh = hsh.deep_dup

    expect(hsh[:a].object_id) != new_hsh[:a].object_id
  end

  it "can deep merge" do
    hsh = { a: [4, 5], b: { c: 3 } }

    new_hsh = hsh.deep_merge({ b: { d: 6 } })

    expect(new_hsh).must_equal({ a: [4, 5], b: { c: 3, d: 6 } })
  end
end
