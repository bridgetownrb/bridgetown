# frozen_string_literal: true

module Bridgetown
  module CoreExt
    class QuestionableString < ::String
      def method_missing(method_name, *args)
        value = method_name.to_s
        if value.end_with?("?")
          value.chop!
          return self == value
        end

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.end_with?("?") || super
      end
    end
  end
end
