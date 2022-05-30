# frozen_string_literal: true

module Bridgetown
  module Filters
    module URLFilters
      extend self

      # Produces an absolute URL based on site.url and site.base_path.
      #
      # @param input [String] the URL to make absolute.
      # @return [String] the absolute URL as a String.
      def absolute_url(input)
        cache = (@context.registers[:cached_absolute_urls] ||= {})
        cache[input] ||= compute_absolute_url(input)
      end

      # Produces a URL relative to the domain root based on site.base_path
      # unless it is already an absolute url with an authority (host).
      #
      # @param input [String] the URL to make relative to the domain root
      # @return [String] a URL relative to the domain root as a String.
      def relative_url(input)
        cache = (@context.registers[:cached_relative_urls] ||= {})
        cache[input] ||= compute_relative_url(input)
      end

      # For string input, adds a prefix of the current site locale to a relative
      # URL, unless it's a default locale and prefix_current_locale config is
      # false. For a resources array input, return a filtered resources array
      # based on the locale.
      #
      # @param input [String, Array] the relative URL, or an array of resources
      # @param use_locale [String] another locale to use beside the current one
      #   (must be in site's `available_locales` config)
      # @return [String, Array] the prefixed relative URL, or filtered resources
      def in_locale(input, use_locale = nil)
        site = @context.registers[:site]
        use_locale ||= site.locale

        # If we're given a collection, filter down and return
        if input.is_a?(Array)
          return input.select do |res|
            res.data[:locale].to_sym == use_locale.to_sym
          end
        end

        if !site.config.prefix_default_locale &&
            use_locale.to_sym == site.config.default_locale
          return input
        end

        return input unless site.config.available_locales.include?(use_locale.to_sym)

        "#{use_locale}/#{input.to_s.delete_prefix("/")}"
      end

      # Strips trailing `/index.html` from URLs to create pretty permalinks
      #
      # @param input [String] the URL with a possible `/index.html`
      # @return [String] a URL with the trailing `/index.html` removed
      def strip_index(input)
        return if input.nil? || input.to_s.empty?

        input.sub(%r!/index\.html?$!, "/")
      end

      # Strips the extension (if present) off a path/URL
      #
      # @param input [Object] value which responds to `to_s`
      # @return [String]
      def strip_extname(input)
        Pathname.new(input.to_s).then do |path|
          path.dirname + path.basename(".*")
        end.to_s
      end

      private

      def compute_absolute_url(input)
        return if input.nil?
        return input.absolute_url if input.respond_to?(:absolute_url)

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
        return input.relative_url if input.respond_to?(:relative_url)

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
