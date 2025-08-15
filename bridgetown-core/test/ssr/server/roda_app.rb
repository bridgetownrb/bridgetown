# frozen_string_literal: true

class RodaApp < Roda
  module OrderIndependenceExample
    module RequestMethods
      def order_independence
        get "order-independence" do
          { it: "works" }
        end
      end
    end
  end

  plugin :bridgetown_server
  plugin OrderIndependenceExample

  # rubocop:disable Lint/EmptyBlock
  plugin(:common_logger, StringIO.new.tap do |io| # swallow logs in tests
    io.singleton_class.define_method(:level=) { |*| }
    io.singleton_class.define_method(:error) { |*| }
    io.singleton_class.define_method(:warn) { |*| }
  end)
  # rubocop:enable Lint/EmptyBlock

  route do |r|
    r.bridgetown
    r.order_independence
  end
end
