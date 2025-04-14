# frozen_string_literal: true

module Bridgetown::Foundation
  class QuestionableString < ::String
    def method_missing(method_name, *args)
      value = method_name.to_s
      return self == value.chop if value.end_with?("?")

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.end_with?("?") || super
    end
  end
end
