# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module OutputSafety
      module ObjectSafety
        def html_safe?
          false
        end
      end

      ::Object.include ObjectSafety

      module NumericSafety
        def html_safe?
          true
        end
      end

      ::Numeric.include NumericSafety
    end
  end
end
