# frozen_string_literal: true

require "minitest_helper"

class TestString < Bridgetown::Foundation::Test
  using Bridgetown::Refinements

  it "has a version number" do
    expect(::Bridgetown::VERSION).wont_be_nil
  end

  it "indents strings" do
    assert_equal "  it\n    is indented\n\n  now", "it\n  is indented\n\nnow".indent(2)
    refute_equal "  it\n    is indented\n\n  now", "it\n  is indented\n\nnow".indent(4)

    str_output = +"indent me!"
    output = capture_stderr do
      str_output.indent!(2, "-")
    end
    assert_equal "  indent me!", str_output
    assert_includes output, "multiple arguments aren't supported by `indent!' in Bridgetown"
    refute_nil "".indent(2)
  end

  it "is questionable" do
    assert "test".questionable.test?
    refute "test".questionable.nope?
  end

  it "starts and ends with" do
    assert "this".starts_with?("th")
    refute "this".starts_with?("ht")

    assert "this".ends_with?("is")
    refute "this".ends_with?("si")
  end

  it "isn't HTML safe by default" do
    refute "<i>unsafe</i>".html_safe?

    assert 123.html_safe?
  end
end
