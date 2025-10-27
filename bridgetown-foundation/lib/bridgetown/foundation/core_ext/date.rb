# frozen_string_literal: true

require "date"

module Bridgetown::Foundation
  module CoreExt
    module Date
      module DateAndTimeComparison
        def <=>(other)
          return super unless other.is_a?(Time)

          to_time <=> other
        end
      end

      #::Date.prepend DateAndTimeComparison
    end
  end
end
