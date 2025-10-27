# frozen_string_literal: true

require "minitest_helper"

class TestDate < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  it "it can compare dates" do
    expect(Date.today <=> Date.today - 2).must_equal 1
    expect(Date.today - 2 <=> Date.today).must_equal(-1)
    expect(Date.today - 1 <=> Date.today - 1).must_equal 0 # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    expect(Date.today - 10).must_be :<, Date.today
    expect(Date.today - 2).must_be :>, Date.today - 4
    expect(Date.today - 1).must_equal Date.today - 1
  end
end
