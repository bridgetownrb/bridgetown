# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module Module
      using RefineExt::Object

      refine ::Module do
        def nested_within?(other)
          return false if self == other

          other_hierarchy = [other, *other.nested_parents]
          nested_parents[-other_hierarchy.length..] == other_hierarchy
        end

        def nested_parents
          return [] unless name

          nesting_segments = name.split("::")[...-1]
          nesting_segments.map.each_with_index do |_nesting_name, index|
            Kernel.const_get(nesting_segments[..-(index + 1)].join("::"))
          end
        end

        def nested_parent
          nested_parents.first
        end

        def nested_name
          name&.split("::")&.last
        end
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::Module
  end
end
