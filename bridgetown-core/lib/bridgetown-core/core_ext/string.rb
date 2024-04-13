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

      module Inquiry
        def inquiry = CoreExt::QuestionableString.new(self)
      end

      ::String.include StartsWithAndEndsWith unless ::String.respond_to?(:starts_with?)
      ::String.include Inquiry unless ::String.respond_to?(:inquiry)
    end
  end
end
