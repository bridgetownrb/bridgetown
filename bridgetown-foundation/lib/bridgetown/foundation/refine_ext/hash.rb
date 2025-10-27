# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module Hash
      refine ::Hash do
        def deep_merge(other, &block)
          dup.deep_merge!(other, &block)
        end

        # Same as #deep_merge, but modifies +self+.
        def deep_merge!(other, &block)
          merge!(other) do |key, this_val, other_val|
            if this_val.respond_to?(:deep_merge) && this_val.deep_merge?(other_val)
              this_val.deep_merge(other_val, &block)
            elsif block_given?
              yield(key, this_val, other_val)
            else
              other_val
            end
          end
        end

        # Returns true if +other+ can be deep merged into +self+. Classes may
        # override this method to restrict or expand the domain of deep mergeable
        # values. Defaults to checking that +other+ is of type +self.class+.
        def deep_merge?(other)
          other.is_a?(self.class)
        end
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::Hash
  end
end
