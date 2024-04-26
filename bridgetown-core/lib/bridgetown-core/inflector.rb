# frozen_string_literal: true

require "dry/inflector"

module Bridgetown
  class Inflector < Dry::Inflector
    def initialize(&) # rubocop:disable Lint/MissingSuper
      @inflections = Dry::Inflector::Inflections.build do |inflections|
        inflections.acronym "HTML"
        inflections.acronym "CSS"
        inflections.acronym "JS"
      end
      configure(&) if block_given?
    end

    def configure
      yield inflections
    end

    # for compatibility with Zeitwerk
    def camelize(basename, *)
      super(basename)
    end
  end
end
