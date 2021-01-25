# frozen_string_literal: true

module Bridgetown
  module Resource
    class Base
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
        @origin = origin.attach_resource(self)
        @data = HashWithDotAccess::Hash.new
      end

      # @param new_data [Hash]
      def data=(new_data)
        unless new_data.is_a?(HashWithDotAccess::Hash)
          raise "#{self.class} data should be of type HashWithDotAccess::Hash"
        end

        @data = new_data
      end

      def read(relative_url: nil)
        origin.read
        @destination = Destination.new(self, relative_url: relative_url) if requires_destination?

        self
      end

      def relative_path
        origin.relative_path
      end

      def relative_path_basename_without_prefix
        return_path = Pathname.new("")
        relative_path.each_filename do |filename|
          return_path += filename unless filename.starts_with?("_")
        end

        (return_path.dirname + return_path.basename(".*")).to_s
      end

      def basename_without_ext
        relative_path.basename(".*").to_s
      end

      def relative_url
        destination&.relative_url
      end

      # TODO: make this fer realz!
      def collection
        site.collections[:posts]
      end

      def date
        data["date"] ||= site.time # TODO: this doesn't reflect documented behavior
      end

      # TODO: this should get populated when data is read
      def taxonomies
        {
          category: [],
        }
      end

      # TODO: needs conditional logic
      def requires_destination?
        true
      end

      def to_s
        output || content || ""
      end

      def inspect
        "#<#{self.class} #{relative_path}>"
      end
    end
  end
end
