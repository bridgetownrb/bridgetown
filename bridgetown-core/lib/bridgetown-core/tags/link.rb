# frozen_string_literal: true

module Bridgetown
  module Tags
    class Link < Liquid::Tag
      include Bridgetown::Filters::URLFilters

      class << self
        def tag_name
          name.split("::").last.downcase
        end
      end

      def initialize(tag_name, relative_path, tokens)
        super

        @relative_path = relative_path.strip
      end

      def render(context)
        @context = context
        site = context.registers[:site]
        relative_path = Liquid::Template.parse(@relative_path).render(context)

        site.each_site_file do |item|
          # Resource engine:
          if item.respond_to?(:relative_url) && item.relative_path.to_s == relative_path
            return item.relative_url
          end
          return relative_url(item) if item.relative_path == relative_path
          # This takes care of the case for static files that have a leading /
          return relative_url(item) if item.relative_path == "/#{relative_path}"
        end

        raise ArgumentError, <<~MSG
          Could not find document '#{relative_path}' in tag '#{self.class.tag_name}'.

          Make sure the document exists and the path is correct.
        MSG
      end
    end
  end
end

Liquid::Template.register_tag(Bridgetown::Tags::Link.tag_name, Bridgetown::Tags::Link)
