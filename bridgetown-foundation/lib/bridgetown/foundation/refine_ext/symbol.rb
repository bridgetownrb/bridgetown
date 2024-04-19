# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module Symbol
      refine ::Symbol do
        def with(...)
          ->(caller, *rest) { caller.public_send(self, *rest, ...) }
        end

        def call(...)
          ->(caller, *rest) { caller.public_send(self, *rest).public_send(...) }
        end
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::Symbol
  end
end
