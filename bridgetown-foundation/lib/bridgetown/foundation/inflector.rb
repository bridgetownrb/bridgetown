# frozen_string_literal: true

require "dry/inflector"

module Bridgetown::Foundation
  class Inflector < Dry::Inflector
    def initialize(&) # rubocop:disable Lint/MissingSuper
      @inflections = Dry::Inflector::Inflections.build do |inflections|
        inflections.acronym "HTML"
        inflections.acronym "CSS"
        inflections.acronym "JS"
      end
      configure(&) if block_given?
    end

    # @yieldparam inflections [Dry::Inflector::Inflections]
    def configure
      yield inflections
    end

    # for compatibility with Zeitwerk
    def camelize(basename, *)
      super(basename)
    end

    def to_s
      "#<Bridgetown::Foundation::Inflector>"
    end
    alias_method :inspect, :to_s

    def ==(other)
      return super unless other.is_a?(Bridgetown::Foundation::Inflector)

      # NOTE: strictly speaking, this might be wrong if two inflector instances have different
      # rule sets…but as this equality check is mainly done within the automated test suite, we
      # just assume two instances are equal. No production apps will need multiple,
      # differently-configured inflectors running at once ;)
      true
    end
  end
end
