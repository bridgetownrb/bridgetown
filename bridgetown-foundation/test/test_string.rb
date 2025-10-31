# frozen_string_literal: true

require "minitest_helper"

class TestString < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  it "has a version number" do
    expect(::Bridgetown::VERSION).not_nil?
  end

  it "indents strings" do
    expect("it\n  is indented\n\nnow".indent(2))
      .equal? "  it\n    is indented\n\n  now"
    expect("it\n  is indented\n\nnow".indent(4))
      .not_equal?("  it\n    is indented\n\n  now")
    expect("".indent(2)).not_nil?
  end

  it "warns if indent receives second argument" do
    str_output = +"indent me!"
    expect { str_output.indent!(2, "-") }.output?(nil, %r!multiple arguments!)
    expect(str_output) == "  indent me!"
    expect { "abc".indent(10) }.silent?
  end

  it "is questionable" do
    expect("test".questionable.test?).true?
    expect("test".questionable.nope?).false?
  end

  it "starts and ends with" do
    expect("this".starts_with?("th")).true?
    expect("this".starts_with?("ht")).false?

    expect("this".ends_with?("is")).true?
    expect("this".ends_with?("si")).false?
  end
end
