# frozen_string_literal: true

module Bridgetown
  module Resource
    class Destination
      # @return [Base]
      attr_accessor :resource

      # @return [String]
      attr_accessor :output_ext

      def initialize(resource)
        @resource = resource
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
        output_ext || ".html"
      end

      def output_path
        path = resource.site.in_dest_dir(URL.unescape_path(relative_url))
        path = File.join(path, "index.html") if relative_url.end_with? "/"
        path
      end
    end
  end
end
