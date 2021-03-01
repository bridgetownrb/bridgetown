# frozen_string_literal: true

module Bridgetown
  module Resource
    class Destination
      # @return [Bridgetown::Resource::Base]
      attr_accessor :resource

      # @return [String]
      attr_accessor :output_ext

      # @param resource [Bridgetown::Resource::Base]
      def initialize(resource)
        @resource = resource
        @output_ext = resource.transformer.final_ext
      end

      def absolute_url
        Addressable::URI.parse(
          resource.site.config.url.to_s + relative_url
        ).normalize.to_s
      end

      def relative_url
        @processor ||= PermalinkProcessor.new(resource)
        @processor.transform
      end

      def final_ext
        output_ext || resource.extname
      end

      def output_path
        path = URL.unescape_path(relative_url)
        path = path.delete_prefix(resource.site.baseurl) if resource.site.baseurl.present?
        path = resource.site.in_dest_dir(path)
        path = File.join(path, "index.html") if relative_url.end_with? "/"
        path
      end
    end
  end
end
