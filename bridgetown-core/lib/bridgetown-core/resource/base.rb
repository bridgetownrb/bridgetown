# frozen_string_literal: true

module Bridgetown
  module Resource
    class Base
      include Bridgetown::DataAccessible
      include Bridgetown::Publishable
      include Bridgetown::LiquidRenderable

      # @return [HashWithDotAccess::Hash]
      attr_reader :data

      # @return [Destination]
      attr_reader :destination

      # @return [Origin]
      attr_reader :origin

      # @return [Bridgetown::Site]
      attr_reader :site

      # @return [String]
      attr_accessor :content, :output

      DATELESS_FILENAME_MATCHER = %r!^(?:.+/)*(.*)(\.[^.]+)$!.freeze
      DATE_FILENAME_MATCHER = %r!^(?>.+/)*?(\d{2,4}-\d{1,2}-\d{1,2})-([^/]*)(\.[^.]+)$!.freeze

      # @param site [Bridgetown::Site]
      # @param origin [Bridgetown::Resource::Origin]
      def initialize(site:, origin:)
        @site = site
        @origin = origin
        @data = HashWithDotAccess::Hash.new
      end

      # @param new_data [Hash]
      def data=(new_data)
        unless new_data.is_a?(HashWithDotAccess::Hash)
          raise "#{self.class} data should be of type HashWithDotAccess::Hash"
        end

        @data = new_data
      end

      def read
        origin.read(self)
        @destination = Destination.new(self)

        self
      end

      def relative_path
        origin.relative_path
      end

      def url
        destination.url
      end

      def path
        if origin.respond_to?(:original_path)
          origin.original_path
        else
          relative_path
        end
      end

      def basename_without_ext
        path.basename(".*").to_s
      end

      def output_ext
        ".html"
      end

      # TODO: make this fer realz!
      def collection
        site.collections[:posts]
      end

      def date
        data["date"] ||= site.time # TODO: this doesn't reflect documented behavior
      end
    end
  end
end
