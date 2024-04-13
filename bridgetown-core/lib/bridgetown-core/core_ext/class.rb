# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Class
      module Descendants
        def descendants
          direct_children = subclasses.select do |klass|
            next true if klass.name.nil? # anonymous class

            # We do this to weed out old classes pre-Zeitwerk reload
            klass == Kernel.const_get(klass.name)
          rescue NameError
            nil
          end

          (direct_children + direct_children.map(&:descendants)).flatten
        end
      end

      ::Class.include Descendants
    end
  end
end
