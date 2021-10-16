# frozen_string_literal: true

module Bridgetown
  module Model
    class BuilderOrigin < Origin
      # @return [Pathname]
      attr_reader :relative_path

      def self.handle_scheme?(scheme)
        scheme == "builder"
      end

      def self.id_for_builder_path(builder, path)
        "builder://#{builder.class.name.gsub("::", ".")}/#{path}"
      end

      def initialize(id)
        self.id = id
        @relative_path = Pathname.new(url.path.delete_prefix("/"))
      end

      def url
        @url ||= URI.parse(id)
      end

      def read
        @data = block_given? ? yield : read_data_from_builder
        @data[:_id_] = id
        @data[:_origin_] = self
        @relative_path = Pathname.new(@data[:_relative_path_]) if @data[:_relative_path_]

        @data
      end

      def exists?
        false
      end

      def read_data_from_builder
        builder = Kernel.const_get(url.host.gsub(".", "::"))
        raise NameError unless builder.respond_to?(:resource_data_for_id)

        builder.resource_data_for_id(id)
      rescue NameError
        raise(
          Bridgetown::Errors::FatalException,
          "Builder not found which can read #{id}"
        )
      end
    end
  end
end
