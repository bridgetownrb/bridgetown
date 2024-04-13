# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module String
      module StartsWithAndEndsWith
        def self.included(klass)
          klass.alias_method :starts_with?, :start_with?
          klass.alias_method :ends_with?, :end_with?
        end
      end

      module Questionable
        def questionable = CoreExt::QuestionableString.new(self)
        alias_method :inquiry, :questionable
        gem_deprecate :inquiry, :questionable, 2024, 12
      end

      ::String.include StartsWithAndEndsWith
      ::String.include Questionable
    end
  end
end
