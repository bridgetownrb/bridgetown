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
        if RUBY_VERSION.start_with?("2.5")
          YAML.safe_load yaml, PERMITTED_CLASSES
        else
          YAML.safe_load yaml, permitted_classes: PERMITTED_CLASSES
        end
      end
    end
  end
end
