# frozen_string_literal: true

module Bridgetown
  module Builders
    class DocumentBuilder
      attr_reader :site

      def initialize(site, path)
        @site = site
        @path = path
        @data = {}.with_indifferent_access
      end

      def front_matter(data)
        @data.merge!(data)
      end

      def _add_document_to_site
        @collection = (@data[:collection] || :posts).to_s
        collection = @site.collections[@collection]
        unless collection
          collection = Collection.new(@site, @collection)
          collection.metadata["output"] = true
          @site.collections[@collection] = collection
        end

        doc = Document.new(File.join(collection.directory, @path), site: @site, collection: collection)
        doc.send(:merge_defaults)
        doc.content = @data[:content]
        @data.delete(:content)

        if @path.start_with?("/")
          pathname = Pathname.new(@path)
          @data[:permalink] = File.join(pathname.dirname, pathname.basename.sub(pathname.extname, "")) + "/"
        end

        doc.merge_data!(@data)
        doc.send(:read_post_data)

        collection.docs << doc
      end

      def method_missing(key, value = nil)
        if respond_to?(key)
          super
        else
          @data[key] = value
        end
      end
    end
  end
end
