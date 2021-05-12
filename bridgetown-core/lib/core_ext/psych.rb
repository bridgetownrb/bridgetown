# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Psych
      # This method is available in Ruby 3, monkey patching for older versions
      def safe_load_file(filename, **kwargs)
        File.open(filename, "r:bom|utf-8") do |f|
          safe_load f, filename: filename, **kwargs
        end
      end

      def bt_safe_load_file(filename, **kwargs)
        kwargs = { permitted_classes: Bridgetown::YAML_PERMITTED_CLASSES }.merge(kwargs)
        safe_load_file(filename, kwargs)
      end

      def bt_safe_load(yaml)
        safe_load yaml, permitted_classes: Bridgetown::YAML_PERMITTED_CLASSES
      end
    end
  end
end
