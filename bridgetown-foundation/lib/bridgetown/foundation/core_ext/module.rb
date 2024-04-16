# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module Module
      module Nested
        def nested_within?(other)
          other.nested_parents.within?(nested_parents[1..])
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

      ::Module.include Nested
    end
  end
end
