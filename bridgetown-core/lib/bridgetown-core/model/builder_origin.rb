# frozen_string_literal: true

module Bridgetown
  module Model
    class BuilderOrigin < Origin
      # @return [Pathname]
      attr_reader :relative_path

      class << self
        def handle_scheme?(scheme)
          scheme == "builder"
        end

        def id_for_builder_path(builder, path)
          "builder://#{builder.class.name.gsub("::", ".")}/#{path}"
        end
      end

      def initialize(id, site: Bridgetown::Current.site, bare_text: false)
        super
        @relative_path = Pathname.new(url.path.delete_prefix("/"))
      end

      def url
        @url ||= Utils.parse_uri(id)
      end

      def read
        @data = block_given? ? yield : read_data_from_builder
        @data[:_id_] = id
        @data[:_origin_] = self
        @relative_path = Pathname.new(@data[:_relative_path_]) if @data[:_relative_path_]

        @data
      end

      def front_matter_line_count = @data[:_front_matter_line_count_]

      def original_path = @data[:_original_path_] || relative_path

      def exists? = false

      def read_data_from_builder
        builder = Kernel.const_get(url.host.gsub(".", "::"))
        raise NameError unless builder.instance_methods.include?(:resource_data_for_id)

        builder.new.resource_data_for_id(id) || raise(NameError)
      rescue NameError
        raise(
          Bridgetown::Errors::FatalException,
          "Builder not found which can read #{id}"
        )
      end
    end
  end
end
