# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module Importer
      # Requires klass#content and klass#front_matter_line_count accessors
      def self.included(klass)
        klass.include Bridgetown::FrontMatter::RubyDSL
      end

      def read_front_matter(file_path)
        file_contents = File.read(
          file_path, **Bridgetown::Utils.merged_file_read_opts(Bridgetown::Current.site, {})
        )
        fm_result = nil
        Loaders.for(self).each do |loader|
          fm_result = loader.read(file_contents, file_path:) and break
        end

        if fm_result
          self.content = fm_result.content
          self.front_matter_line_count = fm_result.line_count
          fm_result.front_matter
        elsif is_a?(Layout)
          self.content = file_contents
          {}
        else
          yaml_data = YAMLParser.load_file(file_path)
          (yaml_data.is_a?(Array) ? { rows: yaml_data } : yaml_data)
        end
      end
    end
  end
end
