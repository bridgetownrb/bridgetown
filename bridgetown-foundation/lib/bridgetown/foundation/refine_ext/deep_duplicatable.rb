# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    # This is a very simplistic algorithm…it essentially just works on the Array/Hash values level,
    # which for our purposes is fine.
    module DeepDuplicatable
      refine ::Hash do
        def deep_dup
          hash = dup
          each do |key, value|
            hash.delete(key)
            new_value = if value.is_a?(Array) || value.is_a?(Hash)
                          value.deep_dup
                        else
                          value.dup
                        end

            if key.is_a?(::String) || key.is_a?(::Symbol)
              hash[key] = new_value
            else
              hash[key.dup] = new_value
            end
          end
          hash
        end
      end

      refine ::Array do
        def deep_dup
          map do |item|
            next item.dup unless item.is_a?(Array) || item.is_a?(Hash)

            item.deep_dup
          end
        end
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::DeepDuplicatable
  end
end
