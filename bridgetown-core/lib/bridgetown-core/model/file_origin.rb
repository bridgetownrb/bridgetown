# frozen_string_literal: true

module Bridgetown
  module Model
    class FileOrigin < Origin
      include Bridgetown::Utils::RubyFrontMatterDSL

      YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze
      RUBY_FRONT_MATTER_REGEXP =
        %r!\A[~`#]{3,}(?:ruby|<%|{%)\s*\n(.*?\n?)^((?:%>|%})?[~`#]{3,}\s*$\n?)!m.freeze

      # @return [String]
      attr_accessor :content

      # @return [Integer]
      attr_accessor :front_matter_line_count

      class << self
        def handle_scheme?(scheme)
          scheme == "file"
        end

        def data_file_extensions
          %w(.yaml .yml .json .csv .tsv .rb).freeze
        end
      end

      def read
        @data = (in_data_collection? ? read_file_data : read_frontmatter) || {}
        @data[:_id_] = id
        @data[:_origin_] = self
        @data[:_collection_] = collection
        @data[:_content_] = content if content

        @data
      rescue SyntaxError => e
        Bridgetown.logger.error "Error:",
                                "Ruby Exception in #{e.message}"
        exit(false)
      rescue StandardError => e
        handle_read_error(e)
        exit(false)
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
            rows:
              CSV.read(original_path,
                       headers: true,
                       encoding: Bridgetown::Current.site.config["encoding"]).map(&:to_hash),
          }
        when ".tsv"
          {
            rows:
              CSV.read(original_path,
                       col_sep: "\t",
                       headers: true,
                       encoding: Bridgetown::Current.site.config["encoding"]).map(&:to_hash),
          }
        when ".rb"
          begin
            instance_eval(File.read(original_path), original_path.to_s, 1).to_h
          rescue StandardError => e
            raise "Missing output value in Ruby code that responds to `to_h'"
          end
        else
          yaml_data = SafeYAML.load_file(original_path)
          yaml_data.is_a?(Array) ? { rows: yaml_data } : yaml_data
        end
      end

      def read_frontmatter
        file_contents = File.read(
          original_path, **Bridgetown::Utils.merged_file_read_opts(Bridgetown::Current.site, {})
        )
        yaml_content = file_contents.match(YAML_FRONT_MATTER_REGEXP)
        if !yaml_content && Bridgetown::Current.site.config.should_execute_inline_ruby?
          ruby_content = file_contents.match(RUBY_FRONT_MATTER_REGEXP)
        end

        if yaml_content
          self.content = yaml_content.post_match
          self.front_matter_line_count = yaml_content[1].lines.size - 1
          SafeYAML.load(yaml_content[1])
        elsif ruby_content
          self.content = ruby_content.post_match
          self.front_matter_line_count = ruby_content[1].lines.size
          instance_eval(ruby_content[1], original_path.to_s, 2).to_h
        elsif Bridgetown::Utils.has_rbfm_header?(original_path)
          ruby_data = instance_eval(
            File.read(original_path).lines[1..-1].join("\n"), original_path.to_s, 2
          )
          ruby_data.is_a?(Array) ? { rows: ruby_data } : ruby_data.to_h
        else
          yaml_data = SafeYAML.load_file(original_path)
          yaml_data.is_a?(Array) ? { rows: yaml_data } : yaml_data
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
