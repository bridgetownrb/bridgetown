# frozen_string_literal: true

module Bridgetown
  module Converters
    class RubyTemplates < Converter
      priority :highest
      input :rb

      def convert(content, convertible)
        erb_view = Bridgetown::ERBView.new(convertible)
        erb_view.instance_eval(
          content, convertible.path.to_s, line_start(convertible)
        ).to_s
      end
    end
  end
end
