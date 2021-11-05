# frozen_string_literal: true

module Bridgetown
  class YAMLParser
    PERMITTED_CLASSES = [Date, Time, Rb].freeze

    class << self
      def load_file(filename, **kwargs)
        kwargs = { permitted_classes: PERMITTED_CLASSES }.merge(kwargs)
        YAML.safe_load_file(filename, **kwargs)
      end

      def load(yaml)
        YAML.safe_load yaml, permitted_classes: PERMITTED_CLASSES
      end
    end
  end
end
