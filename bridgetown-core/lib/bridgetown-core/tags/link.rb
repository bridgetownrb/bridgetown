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
        parsed_path = Liquid::Template.parse(@relative_path).render(context)

        site.each_site_file do |item|
          next unless item.relative_path == parsed_path || item.relative_path == "/#{parsed_path}"

          return Bridgetown::Filters::URLFilters.relative_url(item)
        end

        raise ArgumentError, <<~MSG
          Could not find document '#{parsed_path}' in tag '#{self.class.tag_name}'.

          Make sure the document exists and the path is correct.
        MSG
      end
    end
  end
end

Liquid::Template.register_tag(Bridgetown::Tags::Link.tag_name, Bridgetown::Tags::Link)
