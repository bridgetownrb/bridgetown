# frozen_string_literal: true

class RodaApp < Bridgetown::Rack::Roda
  # rubocop:disable Lint/EmptyBlock
  plugin(:common_logger, StringIO.new.tap do |io| # swallow logs in tests
    io.singleton_class.define_method(:level=) { |*| }
    io.singleton_class.define_method(:error) { |*| }
    io.singleton_class.define_method(:warn) { |*| }
  end)
  # rubocop:enable Lint/EmptyBlock

  plugin :bridgetown_ssr do |site|
    site.data.iterations ||= 0
    site.data.iterations += 1
  end

  route(&:bridgetown)
end
