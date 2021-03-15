# frozen_string_literal: true

module Bridgetown
  module Model
    class FileOrigin < Origin
      YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

      class << self
        def handle_scheme?(scheme)
          scheme == "file"
        end

        def data_file_extensions
          %w(.yaml .yml .json .csv .tsv).freeze
        end
      end

      def read
        @data = (in_data_collection? ? read_file_data : read_frontmatter) || {}
        @data[:_id_] = id
        @data[:_origin_] = self
        @data[:_collection_] = collection
        @data[:_content_] = @content if @content

        @data
      rescue StandardError => e
        handle_read_error(e)
      end

      def url
        @url = URI.parse(id)
      end

      def relative_path
        @relative_path ||= Pathname.new(
          Addressable::URI.unescape(url.path.delete_prefix("/"))
        )
      end

      def collection
        return @collection if @collection

        collection_name = if url.host.ends_with?(".collection")
                            url.host.chomp(".collection")
                          else
                            "pages"
                          end
        @collection = Bridgetown::Current.site.collections[collection_name]
      end

      def original_path
        @original_path ||= relative_path.expand_path(Bridgetown::Current.site.source)
      end

      def exists?
        File.exist?(original_path)
      end

      private

      def in_data_collection?
        original_path.extname.downcase.in?(self.class.data_file_extensions) &&
          collection.data?
      end

      def read_file_data
        case original_path.extname.downcase
        when ".csv"
          {
            array:
              CSV.read(original_path,
                       headers: true,
                       encoding: Bridgetown::Current.site.config["encoding"]).map(&:to_hash),
          }
        when ".tsv"
          {
            array:
              CSV.read(original_path,
                       col_sep: "\t",
                       headers: true,
                       encoding: Bridgetown::Current.site.config["encoding"]).map(&:to_hash),
          }
        else
          yaml_data = SafeYAML.load_file(original_path)
          yaml_data.is_a?(Array) ? { array: yaml_data } : yaml_data
        end
      end

      def read_frontmatter
        @content = File.read(
          original_path, **Bridgetown::Utils.merged_file_read_opts(Bridgetown::Current.site, {})
        )
        content_match = @content.match(YAML_FRONT_MATTER_REGEXP)
        if content_match
          @content = content_match.post_match
          SafeYAML.load(content_match[1])
        else
          yaml_data = SafeYAML.load_file(original_path)
          yaml_data.is_a?(Array) ? { array: yaml_data } : yaml_data
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

        if Bridgetown::Current.site.config["strict_front_matter"] ||
            error.is_a?(Bridgetown::Errors::FatalException)
          raise error
        end
      end
    end
  end
end
