# frozen_string_literal: true

module Bridgetown
  module Builders
    class DocumentBuilder
      attr_reader :site

      def initialize(site, path)
        @site = site
        @path = path
        @data = ActiveSupport::HashWithIndifferentAccess.new
      end

      def front_matter(data)
        @data.merge!(data)
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def _add_document_to_site
        @collection = (@data[:collection] || :posts).to_s
        collection = @site.collections[@collection]
        unless collection
          collection = Collection.new(@site, @collection)
          collection.metadata["output"] = true
          @site.collections[@collection] = collection
        end

        doc = Document.new(
          File.join(collection.directory, @path),
          site: @site,
          collection: collection
        )
        doc.send(:merge_defaults)
        doc.content = @data[:content]
        @data.delete(:content)

        if @path.start_with?("/")
          pathname = Pathname.new(@path)
          @data[:permalink] = File.join(
            pathname.dirname,
            pathname.basename.sub(pathname.extname, "")
          ) + "/"
        end

        doc.merge_data!(@data)
        doc.send(:read_post_data)

        collection.docs << doc
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(key, value = nil)
        if respond_to?(key)
          super
        else
          @data[key] = value
        end
      end
      # rubocop:enable Style/MissingRespondToMissing
    end
  end
end
