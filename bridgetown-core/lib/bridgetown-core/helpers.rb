# frozen_string_literal: true

module Bridgetown
  class RubyTemplateView
    class Helpers
      include Bridgetown::Filters

      attr_reader :view, :site

      Context = Struct.new(:registers)

      def initialize(view, site)
        @view = view
        @site = site

        # duck typing for Liquid context
        @context = Context.new({ site: site })
      end

      def webpack_path(asset_type)
        Bridgetown::Utils.parse_webpack_manifest_file(site, asset_type.to_s)
      end

      # @param pairs [Hash] A hash of key/value pairs.
      #
      # @return [String] Space-separated keys where the values are truthy.
      def class_map(pairs = {})
        pairs.select { |_key, truthy| truthy }.keys.join(" ")
      end

      # This helper will generate the correct permalink URL for the file path.
      #
      # @param relative_path [String, Object] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md", or object that responds to `url`
      # @return [String] the permalink URL for the file
      # @raise [ArgumentError] if the file cannot be found
      def url_for(relative_path)
        path_string = !relative_path.is_a?(String) ? relative_path.url : relative_path

        return path_string if path_string.start_with?("/", "http")

        site.each_site_file do |item|
          if item.relative_path == path_string || item.relative_path == "/#{path_string}"
            return relative_url(item)
          end
        end

        raise ArgumentError, <<~MSG
          Could not find document '#{relative_path}' in 'url_for' helper.

          Make sure the document exists and the path is correct.
        MSG
      end
      alias_method :link, :url_for

      # This helper will generate the correct permalink URL for the file path.
      #
      # @param text [String] the content inside the anchor tag
      # @param relative_path [String, Object] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md", or object that responds to `url`
      # @param options [Hash] key-value pairs of HTML attributes to add to the tag
      # @return [String] the anchor tag HTML
      # @raise [ArgumentError] if the file cannot be found
      def link_to(text, relative_path, options = {})
        segments = []
        segments << "a"
        segments << "href=\"#{url_for(relative_path)}\""
        options.each do |attr, option|
          attr = attr.to_s.tr("_", "-")
          segments << "#{attr}=\"#{Utils.xml_escape(option)}\""
        end
        "<#{segments.join(" ")}>#{text}</a>"
      end

      # Forward all arguments to I18n.t method
      #
      # @return [String] the translated string
      # @see I18n
      def t(*args)
        I18n.send :t, *args
      end
    end
  end
end
