# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bridgetown-foundation"

require "minitest/autorun"

require "stringio"

class Minitest::Test
  # solution from: https://stackoverflow.com/a/4459463
  def capture_stderr
    # The output stream must be an IO-like object. In this case we capture it in
    # an in-memory IO object so we can return the string value. You can assign any
    # IO object here.
    previous_stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    # Restore the previous value of stderr (typically equal to STDERR).
    $stderr = previous_stderr
  end
end
