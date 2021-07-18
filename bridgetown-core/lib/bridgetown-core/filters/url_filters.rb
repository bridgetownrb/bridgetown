# frozen_string_literal: true

module Bridgetown
  module Filters
    module URLFilters
      extend self

      # Produces an absolute URL based on site.url and site.base_path.
      #
      # input - the URL to make absolute.
      #
      # Returns the absolute URL as a String.
      def absolute_url(input)
        cache = (@context.registers[:cached_absolute_urls] ||= {})
        cache[input] ||= compute_absolute_url(input)
      end

      # Produces a URL relative to the domain root based on site.base_path
      # unless it is already an absolute url with an authority (host).
      #
      # input - the URL to make relative to the domain root
      #
      # Returns a URL relative to the domain root as a String.
      def relative_url(input)
        cache = (@context.registers[:cached_relative_urls] ||= {})
        cache[input] ||= compute_relative_url(input)
      end

      # Strips trailing `/index.html` from URLs to create pretty permalinks
      #
      # input - the URL with a possible `/index.html`
      #
      # Returns a URL with the trailing `/index.html` removed
      def strip_index(input)
        return if input.nil? || input.to_s.empty?

        input.sub(%r!/index\.html?$!, "/")
      end

      # Strips the extension (if present) off a path/URL
      #
      # @param input [Object] value which responds to `to_s`
      # @return [String]
      def strip_extname(input)
        Pathname.new(input.to_s).yield_self do |path|
          path.dirname + path.basename(".*")
        end.to_s
      end

      private

      def compute_absolute_url(input)
        return if input.nil?

        input = input.url if input.respond_to?(:url)
        return input if Addressable::URI.parse(input.to_s).absolute?

        site = @context.registers[:site]
        site_url = site.config["url"]
        return relative_url(input) if site_url.nil? || site_url == ""

        Addressable::URI.parse(
          site_url.to_s + relative_url(input)
        ).normalize.to_s
      end

      def compute_relative_url(input)
        return if input.nil?

        input = input.url if input.respond_to?(:url)
        return input if Addressable::URI.parse(input.to_s).absolute?

        site = @context.registers[:site]
        parts = [site.base_path.chomp("/"), input]
        Addressable::URI.parse(
          parts.compact.map { |part| ensure_leading_slash(part.to_s) }.join
        ).normalize.to_s
      end

      def ensure_leading_slash(input)
        return input if input.nil? || input.empty? || input.start_with?("/")

        "/#{input}"
      end
    end
  end
end
