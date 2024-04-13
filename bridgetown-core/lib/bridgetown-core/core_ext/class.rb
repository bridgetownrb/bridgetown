# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Class
      module Descendants
        def descendants
          direct_children = subclasses.select do |klass|
            klass == Kernel.const_get(klass.name)
          rescue NameError
            nil
          end

          (direct_children + direct_children.map(&:descendants)).flatten
        end
      end

      ::Class.include Descendants unless ::Class.respond_to?(:descendants)
    end
  end
end
