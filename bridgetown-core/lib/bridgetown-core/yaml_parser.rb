# frozen_string_literal: true

module Bridgetown
  class YAMLParser
    PERMITTED_CLASSES = [Date, Time, Rb].freeze

    class << self
      def load_file(filename, **kwargs)
        YAML.safe_load_file filename, **merge_permitted_classes(kwargs)
      end

      def load(yaml, **kwargs)
        YAML.safe_load yaml, **merge_permitted_classes(kwargs)
      end

      private

      def merge_permitted_classes(kwargs)
        if kwargs.key?(:permitted_classes)
          kwargs[:permitted_classes] |= PERMITTED_CLASSES
        else
          kwargs[:permitted_classes] = PERMITTED_CLASSES
        end

        kwargs
      end
    end
  end
end
