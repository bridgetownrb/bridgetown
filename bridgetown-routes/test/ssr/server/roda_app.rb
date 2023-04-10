# frozen_string_literal: true

class RodaApp < Roda
  plugin :bridgetown_server

  # rubocop:disable Lint/EmptyBlock
  plugin(:common_logger, StringIO.new.tap do |io| # swallow logs in tests
    io.singleton_class.define_method(:level=) { |*| }
    io.singleton_class.define_method(:error) { |*| }
    io.singleton_class.define_method(:warn) { |*| }
  end)
  # rubocop:enable Lint/EmptyBlock

  route(&:bridgetown)
end
