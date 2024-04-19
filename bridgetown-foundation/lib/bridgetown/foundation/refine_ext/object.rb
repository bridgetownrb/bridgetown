# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module Object
      refine ::Object do
        # This method lets you check if the receiver is "within" the other object. In most cases,
        # this check is accomplished via the `include?` method…aka, `10.within? [5, 10]` would
        # return `true` as `[5, 10].include? 10` is true. And String/String comparison are
        # case-insensivitve.
        #
        # However, for certain comparison types: Module/Class, Hash, and Set, the lesser-than (`<`)
        # operator is used instead. This is so you can check `BigDecimal.within? Numeric`,
        # `{easy_as: 123}.within?({indeed: "it's true", easy_as: 123})`, and if a Set is a
        # `proper_subset?` of another Set.
        #
        # For Array/Array comparisons, a difference is checked, so `[1,2].within? [3,2,1]` is true,
        # but `[1,2].within? [2,3]` is false.
        #
        # Also for Range, the `cover?` method is used instead of `include?`.
        #
        # @param other [Object] for determining if receiver lies within this value
        # @return [Boolean]
        def within?(other) # rubocop:disable Metrics
          # rubocop:disable Style/IfUnlessModifier
          if is_a?(Module) && other.is_a?(Module)
            return self < other
          end

          if (is_a?(Hash) && other.is_a?(Hash)) || (is_a?(Set) && other.is_a?(Set))
            return self < other
          end

          if is_a?(Array) && other.is_a?(Array)
            return false if empty?

            return difference(other).empty?
          end

          if other.is_a?(Range)
            return other.cover?(self) == true
          end

          if is_a?(::String) && other.is_a?(::String)
            return other.downcase.include?(downcase)
          end

          other&.include?(self) == true
          # rubocop:enable Style/IfUnlessModifier
        rescue NoMethodError
          false
        end

        # NOTE: if you _really_ need to preserve Active Support's `in?` functionality, you can just
        #   require "active_support/core_ext/object/inclusion"
        def in?(...) = Bridgetown::Foundation.deprecation_warning(
          self, :in?, :within?, 2024, 12
        ).then { within?(...) }
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::Object
  end
end
