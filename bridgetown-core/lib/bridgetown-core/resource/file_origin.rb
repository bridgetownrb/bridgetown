# frozen_string_literal: true

module Bridgetown
  module Resource
    class FileOrigin < Origin
      # @return [Pathname]
      attr_accessor :original_path

      def initialize(collection:, original_path: nil, relative_path: nil)
        super(collection: collection, relative_path: relative_path)

        @original_path = if relative_path
                           Pathname.new(
                             collection.site.in_source_dir(relative_path)
                           )
                         else
                           Pathname.new(original_path)
                         end
        unless relative_path
          @relative_path = @original_path.relative_path_from(collection.site.source)
        end
      end

      def read
        raise "Missing path for #{resource}" unless original_path

        resource.content = File.read(
          original_path, **Bridgetown::Utils.merged_file_read_opts(resource.site, {})
        )

        self.unprocessed_data = if self.class.data_file_extensions.include?(
          original_path.extname.downcase
        )
                                  read_file_data
                                else
                                  read_frontmatter
                                end.with_dot_access
        Bridgetown::Utils.deep_merge_hashes!(resource.data, unprocessed_data)
      rescue StandardError => e
        handle_read_error(e)
      end

      private

      def read_file_data
        case original_path.extname.downcase
        when ".csv"
          {
            array:
              CSV.read(original_path,
                       headers: true,
                       encoding: resource.site.config["encoding"]).map(&:to_hash),
          }
        when ".tsv"
          {
            array:
              CSV.read(original_path,
                       col_sep: "\t",
                       headers: true,
                       encoding: resource.site.config["encoding"]).map(&:to_hash),
          }
        else
          SafeYAML.load_file(original_path)
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
