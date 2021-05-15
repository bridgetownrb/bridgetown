# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Psych
      module SafeLoadFile
        def safe_load_file(filename, **kwargs)
          File.open(filename, "r:bom|utf-8") do |f|
            if RUBY_VERSION.start_with?("2.5")
              safe_load f, kwargs[:permitted_classes], [], false, filename
            else
              safe_load f, filename: filename, **kwargs
            end
          end
        end
      end
    end
  end
end
