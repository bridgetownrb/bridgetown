# frozen_string_literal: true

module Bridgetown
  module LiquidExtensions
    # Lookup a Liquid variable in the given context.
    #
    # @param context [Liquid::Context]
    # @param variable [String] the variable name
    # @return [Object] value of the variable in the context or the variable name if not found
    def lookup_variable(context, variable)
      lookup = context

      variable.split(".").each do |value|
        lookup = lookup[value]
      end

      lookup || variable
    end
  end
end
