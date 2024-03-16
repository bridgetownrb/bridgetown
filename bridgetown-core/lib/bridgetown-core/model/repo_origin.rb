# frozen_string_literal: true

module Bridgetown
  module Model
    class RepoOrigin < Origin
      include Bridgetown::FrontMatterImporter
      include Bridgetown::Utils::RubyFrontMatterDSL

      YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze
      RUBY_FRONT_MATTER_HEADER = %r!\A[~`#-]{3,}(?:ruby|<%|{%)\s*\n!.freeze
      RUBY_FRONT_MATTER_REGEXP =
        %r!#{RUBY_FRONT_MATTER_HEADER.source}(.*?\n?)^((?:%>|%})?[~`#-]{3,}\s*$\n?)!m.freeze

      # @return [String]
      attr_accessor :content

      # @return [Integer]
      attr_accessor :front_matter_line_count

      class << self
        def handle_scheme?(scheme)
          scheme == "repo"
        end

        def data_file_extensions
          %w(.yaml .yml .json .csv .tsv .rb).freeze
        end

        # Initializes a new repo object using a collection and a relative source path.
        # You'll need to use this when you want to create and save a model to the source.
        #
        # @param collection [Bridgetown::Collection, String, Symbol] either a collection
        #   label or Collection object
        # @param relative_path [Pathname, String] the source path of the file to save
        def new_with_collection_path(collection, relative_path, site: Bridgetown::Current.site)
          collection = collection.label if collection.is_a?(Bridgetown::Collection)

          new("repo://#{collection}.collection/#{relative_path}", site: site)
        end
      end

      def read
        begin
          @data = (in_data_collection? ? read_file_data : read_front_matter(original_path)) || {}
        rescue SyntaxError => e
          Bridgetown.logger.error "Error:",
                                  "Ruby Exception in #{e.message}"
        rescue StandardError => e
          handle_read_error(e)
        end

        @data ||= {}
        @data[:_id_] = id
        @data[:_origin_] = self
        @data[:_collection_] = collection
        @data[:_content_] = content if content

        @data
      end

      def write(model)
        if File.exist?(original_path) && !Bridgetown::Utils.has_yaml_header?(original_path)
          raise Bridgetown::Errors::InvalidYAMLFrontMatterError,
                "Only existing files containing YAML front matter can be overwritten by the model"
        end

        contents = "#{front_matter_to_yaml(model)}---\n\n#{model.content}"

        # Create folders if necessary
        dir = File.dirname(original_path)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        File.write(original_path, contents)

        true
      end

      def url
        @url ||= URI.parse(id)
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
        @collection = site.collections[collection_name]
      end

      def original_path
        @original_path ||= relative_path.expand_path(site.source)
      end

      def exists?
        File.exist?(original_path)
      end

      private

      def in_data_collection?
        original_path.extname.downcase.in?(self.class.data_file_extensions) &&
          collection.data?
      end

      def read_file_data # rubocop:todo Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
        case original_path.extname.downcase
        when ".csv"
          {
            rows:
              CSV.read(original_path,
                       headers: true,
                       encoding: site.config["encoding"]).map(&:to_hash),
          }
        when ".tsv"
          {
            rows:
              CSV.read(original_path,
                       col_sep: "\t",
                       headers: true,
                       encoding: site.config["encoding"]).map(&:to_hash),
          }
        when ".rb"
          process_ruby_data(File.read(original_path), original_path, 1)
        when ".json"
          json_data = JSON.parse(File.read(original_path))
          json_data.is_a?(Array) ? { rows: json_data } : json_data
        else
          yaml_data = YAMLParser.load_file(original_path)
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

        if site.config["strict_front_matter"] ||
            error.is_a?(Bridgetown::Errors::FatalException)
          raise error
        end
      end

      def front_matter_to_yaml(model)
        data = model.data_attributes.to_h
        data = data.deep_merge(data) do |_, _, v|
          case v
          when DateTime
            v.to_time
          when Symbol
            v.to_s
          else
            v
          end
        end
        data.each do |k, v|
          data.delete(k) if v.nil?
        end

        data.to_yaml
      end
    end
  end
end
