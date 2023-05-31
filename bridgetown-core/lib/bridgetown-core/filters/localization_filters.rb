# frozen_string_literal: true

module Bridgetown
  module Filters
    module LocalizationFilters
      def l(input)
        I18n.l(input.to_s)
      end
    end
  end
end
