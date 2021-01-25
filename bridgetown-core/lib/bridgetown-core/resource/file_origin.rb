# frozen_string_literal: true

module Bridgetown
  module Resource
    class FileOrigin < Origin
      # @return [Pathname]
      attr_accessor :original_path

      def initialize(original_path:)
        @original_path = Pathname.new(original_path)
      end

      def attach_resource(resource)
        super
        @relative_path = original_path.relative_path_from(resource.site.source)
        self
      end

      def read
        raise "Missing path for #{resource}" unless original_path

        resource.content = File.read(
          original_path, **Bridgetown::Utils.merged_file_read_opts(resource.site, {})
        )

        if self.class.data_file_extensions.include? original_path.extname.downcase
          Bridgetown::Utils.deep_merge_hashes!(resource.data, read_file_data)
        else
          Bridgetown::Utils.deep_merge_hashes!(resource.data, read_frontmatter)
        end
      rescue StandardError => e
        handle_read_error(e)
      end

      private

      def read_file_data
        case original_path.extname.downcase
        when ".csv"
          CSV.read(original_path,
                   headers: true,
                   encoding: resource.site.config["encoding"]).map(&:to_hash)
        when ".tsv"
          CSV.read(original_path,
                   col_sep: "\t",
                   headers: true,
                   encoding: resource.site.config["encoding"]).map(&:to_hash)
        else
          SafeYAML.load_file(path)
        end
      end

      def read_frontmatter
        content_match = resource.content.match(YAML_FRONT_MATTER_REGEXP)
        if content_match
          resource.content = content_match.post_match
          SafeYAML.load(content_match[1])
        else
          {}
        end
      end

      def handle_read_error(error)
        if error.is_a? Psych::SyntaxError
          Bridgetown.logger.error "Error:",
                                  "YAML Exception reading #{original_path}: #{error.message}"
        else
          Bridgetown.logger.error "Error:",
                                  "could not read file #{original_path}: #{error.message}"
        end

        if resource.site.config["strict_front_matter"] ||
            error.is_a?(Bridgetown::Errors::FatalException)
          raise error
        end
      end
    end
  end
end
