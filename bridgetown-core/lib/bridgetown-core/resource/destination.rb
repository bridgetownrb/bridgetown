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
        warn_on_rails_style_extension
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
        if resource.site.base_path.present?
          path = path.delete_prefix resource.site.base_path(strip_slash_only: true)
        end
        path = resource.site.in_dest_dir(path)
        path = File.join(path, "index.html") if relative_url.end_with? "/"
        path
      end

      def write(output)
        path = output_path
        FileUtils.mkdir_p(File.dirname(path))
        Bridgetown.logger.debug "Writing:", path
        File.write(path, output, mode: "wb")
      end

      private

      def warn_on_rails_style_extension
        return unless resource.relative_path.fnmatch?("*.{html,json,js}.*", File::FNM_EXTGLOB)

        Bridgetown.logger.warn("Uh oh!", "You're using a Rails-style filename extension in:")
        Bridgetown.logger.warn("", resource.relative_path)
        Bridgetown.logger.warn(
          "", "Instead, you can use either the desired output file extension or set a permalink."
        )
        Bridgetown.logger.warn(
          "For more info:",
          "https://www.bridgetownrb.com/docs/template-engines/erb-and-beyond#extensions-and-permalinks"
        )
        Bridgetown.logger.warn("")
      end
    end
  end
end
