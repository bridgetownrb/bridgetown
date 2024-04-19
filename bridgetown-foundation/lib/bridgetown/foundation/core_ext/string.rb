# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module String
      module StartsWithAndEndsWith
        def self.included(klass)
          klass.alias_method :starts_with?, :start_with?
          klass.alias_method :ends_with?, :end_with?
        end
      end

      ::String.include StartsWithAndEndsWith
    end
  end
end
