# frozen_string_literal: true

module Bridgetown
  module Resource
    class Destination
      # @return [Base]
      attr_accessor :resource

      def initialize(resource, relative_url: nil)
        @resource = resource
        @relative_url = relative_url
      end

      def relative_url
        @relative_url || generate_url_from_data
      end

      def final_ext
        ".html" # TODO: this should be dynamic
      end

      private

      def generate_url_from_data
        @processor ||= PermalinkProcessor.new(resource)
        @processor.transform
      end
    end
  end
end
