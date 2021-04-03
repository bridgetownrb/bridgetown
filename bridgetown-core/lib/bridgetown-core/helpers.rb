# frozen_string_literal: true

module Bridgetown
  class RubyTemplateView
    class Helpers
      include Bridgetown::Filters
      include Bridgetown::Filters::FromLiquid

      # @return [Bridgetown::RubyTemplateView]
      attr_reader :view

      # @return [Bridgetown::Site]
      attr_reader :site

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

      # Convert a Markdown string into HTML output.
      #
      # @param input [String] the Markdown to convert, if no block is passed
      # @return [String]
      def markdownify(input = nil, &block)
        content = Bridgetown::Utils.reindent_for_markdown(
          block.nil? ? input.to_s : view.capture(&block)
        )
        converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
        safe(converter.convert(content).strip)
      end

      # This helper will generate the correct permalink URL for the file path.
      #
      # @param relative_path [String, Object] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md", or object that responds to either
      #   `url` or `relative_url`
      # @return [String] the permalink URL for the file
      def url_for(relative_path)
        if relative_path.respond_to?(:relative_url)
          return safe(relative_path.relative_url) # new resource engine
        elsif relative_path.respond_to?(:url)
          return safe(relative_url(relative_path.url)) # old legacy engine
        elsif relative_path.start_with?("/", "http")
          return safe(relative_path)
        end

        find_relative_url_for_path(relative_path)
      end
      alias_method :link, :url_for

      # @param relative_path [String] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md"
      # @raise [ArgumentError] if the file cannot be found
      def find_relative_url_for_path(relative_path)
        site.each_site_file do |item|
          if item.relative_path == relative_path || item.relative_path == "/#{relative_path}"
            safe(item.respond_to?(:relative_url) ? item.relative_url : relative_url(item))
          end
        end

        raise ArgumentError, <<~MSG
          Could not find document '#{relative_path}' in 'url_for' helper.

          Make sure the document exists and the path is correct.
        MSG
      end

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
        safe("<#{segments.join(" ")}>#{text}</a>")
      end

      # Forward all arguments to I18n.t method
      #
      # @return [String] the translated string
      # @see I18n
      def t(*args)
        I18n.send :t, *args
      end

      # For template contexts where ActiveSupport's output safety is loaded, we
      # can ensure a string has been marked safe
      #
      # @param input [Object]
      # @return [String]
      def safe(input)
        input.to_s.yield_self do |str|
          str.respond_to?(:html_safe) ? str.html_safe : str
        end
      end
    end
  end
end
