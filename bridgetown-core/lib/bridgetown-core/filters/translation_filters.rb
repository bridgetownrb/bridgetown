# frozen_string_literal: true

module Bridgetown
  module Filters
    module TranslationFilters
      def t(input)
        I18n.t(input.to_s)
      end
    end
  end
end
