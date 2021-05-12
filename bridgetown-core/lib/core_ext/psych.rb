module Bridgetown
  module CoreExt
    module Psych
      def safe_load_file(filename, **kwargs)
        File.open(filename, 'r:bom|utf-8') { |f|
          self.safe_load f, filename: filename, **kwargs
        }
      end
    end
  end
end