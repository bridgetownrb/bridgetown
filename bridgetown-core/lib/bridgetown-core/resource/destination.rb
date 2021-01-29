# frozen_string_literal: true

module Bridgetown
  module Resource
    class Destination
      # @return [Base]
      attr_accessor :resource

      def initialize(resource, relative_url: nil)
        @resource = resource
        @relative_url = relative_url
      end

      def absolute_url
        Addressable::URI.parse(
          resource.site.config.url.to_s + relative_url
        ).normalize.to_s
      end

      def relative_url
        @relative_url || generate_url_from_data
      end

      def final_ext
        ".html" # TODO: this should be dynamic
      end

      def output_path
        return @output_path if @output_path

        path = resource.site.in_dest_dir(URL.unescape_path(relative_url))
        if relative_url.end_with? "/"
          path = File.join(path, "index.html")
        else
          path << final_ext unless path.end_with? final_ext
        end
        @output_path = path
      end

      private

      def generate_url_from_data
        @processor ||= PermalinkProcessor.new(resource)
        @processor.transform
      end
    end
  end
end
