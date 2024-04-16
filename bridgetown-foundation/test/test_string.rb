# frozen_string_literal: true

require "test_helper"

class TestString < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bridgetown::Foundation::VERSION
  end

  def test_string_indentation
    assert_equal "  it\n    is indented\n\n  now", "it\n  is indented\n\nnow".indent(2)
    refute_equal "  it\n    is indented\n\n  now", "it\n  is indented\n\nnow".indent(4)

    str_output = +"indent me!"
    output = capture_stderr do
      str_output.indent!(2, "-")
    end
    assert_equal "  indent me!", str_output
    assert_includes output, "multiple arguments aren't supported by `indent!' in Bridgetown"
  end

  def test_questionable
    assert "test".questionable.test?
    refute "test".questionable.nope?
  end

  def test_starts_ends_with
    assert "this".starts_with?("th")
    refute "this".starts_with?("ht")

    assert "this".ends_with?("is")
    refute "this".ends_with?("si")
  end
end
