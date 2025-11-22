# frozen_string_literal: true

require "samovar"
require "freyia"

# Monkey-patch to support `--key=value`
Samovar::Options.class_eval do
  def parse(input, parent = nil, default = nil) # rubocop:disable Metrics
    values = (default || @defaults).dup

    while option = @keyed[input.first] || @keyed[input.first&.split("=")&.first] # rubocop:disable Lint/AssignmentInCondition
      result = option.parse(input)
      values[option.key] = result unless result.nil?
    end

    # Validate required options
    @ordered.each do |option|
      if option.required && !values.key?(option.key)
        raise Samovar::MissingValueError.new(parent, option.key)
      end
    end

    values
  end
end

Samovar::ValueFlag.class_eval do
  # Parse this flag from the input.
  #
  # @parameter input [Array(String)] The command-line arguments.
  # @returns [String | Symbol | Nil] The parsed value.
  def parse(input)
    if prefix?(input.first)
      # Whether we are expecting to parse a value from input:
      if @value
        # Get the actual value from input:
        _, value = input.shift(2)
        value
      else
        # Otherwise, we are just a boolean flag:
        input.shift
        key
      end
    elsif prefix?(input.first.split("=").first)
      input.shift(1)[0].split("=").last

    end
  end
end

module Bridgetown
  class Command < Samovar::Command
    def self.summary = description
  end
end
