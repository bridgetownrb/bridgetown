# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Object
      module WithinOther
        # This method lets you check if the receiver is "within" the other object. In most cases,
        # this check is accomplished via the `include?` method…aka, `10.within? [5, 10]` would
        # return `true` as `[5, 10].include? 10` is true.
        #
        # However, for certain comparison types: Module/Class, Hash, and Set, the lesser-than (`<`)
        # operator is used instead. This is so you can check `BigDecimal.within? Numeric`,
        # `{easy_as: 123}.within?({indeed: "it's true", easy_as: 123})`, and if a Set is a
        # `proper_subset?` of another Set.
        #
        # Also for Range, the `cover?` method is used instead of `include?`.
        #
        # @param other [Object] for determining if receiver lies within this value
        # @return [Boolean]
        def within?(other) # rubocop:disable Metrics
          # rubocop:disable Style/CaseEquality
          if self.class < other.class && (Module === other || Hash === other || Set === other)
            return self < other
          end

          if Range === other
            other&.cover?(self) == true
          else
            other&.include?(self) == true
          end
          # rubocop:enable Style/CaseEquality
        rescue NoMethodError
          false
        end
      end

      ::Object.include WithinOther unless ::Object.respond_to?(:within?)

      # NOTE: if you _really_ need to preserve Active Support's `in?` functionality, you can just
      #   require "active_support/core_ext/object/inclusion"
      unless ::Object.respond_to?(:in)
        ::Object.class_eval do
          extend Gem::Deprecate
          alias_method :in?, :within?
          deprecate :in?, :within?, 2024, 12
        end
      end
    end
  end
end
