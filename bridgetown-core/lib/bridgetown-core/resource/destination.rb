# frozen_string_literal: true

module Bridgetown
  module Resource
    class Destination
      # @return [Base]
      attr_accessor :resource

      def initialize(resource)
        @resource = resource
      end

      def url
        @url ||= Bridgetown::URL.new(
          template: url_template,
          placeholders: url_placeholders,
          permalink: permalink
        ) # .to_s
      end

      # The URL template to render collection's documents at.
      #
      # Returns the URL template to render collection's documents at.
      def url_template
        @url_template ||= Bridgetown::Utils.add_permalink_suffix("/:categories/:year/:month/:day/:title/", resource.site.permalink_style)
      end

      # Construct a Hash of key-value pairs which contain a mapping between
      #   a key in the URL template and the corresponding value for this document.
      #
      # Returns the Hash of key-value pairs for replacement in the URL.
      def url_placeholders
        @url_placeholders ||= Bridgetown::Drops::UrlDrop.new(resource)
      end

      # The permalink for this Document.
      # Permalink is set via the data Hash.
      #
      # Returns the permalink or nil if no permalink was set in the data.
      def permalink
        resource.data.permalink
      end
    end
  end
end
