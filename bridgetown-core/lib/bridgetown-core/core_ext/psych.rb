# frozen_string_literal: true

module Bridgetown
  module CoreExt
    module Psych
      module SafeLoadFile
        def safe_load_file(filename, **kwargs)
          File.open(filename, "r:bom|utf-8") do |f|
            safe_load f, filename:, **kwargs
          end
        end
      end
    end
  end
end
