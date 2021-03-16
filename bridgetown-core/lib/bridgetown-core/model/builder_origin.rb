# frozen_string_literal: true

module Bridgetown
  module Model
    # Abstract Superclass
    class BuilderOrigin < Origin
      # @return [Pathname]
      attr_reader :relative_path

      # Override in subclass
      def self.handle_scheme?(scheme)
        scheme == "builder"
      end

      def initialize(id)
        self.id = id
        @relative_path = Pathname.new(id.delete_prefix("builder://"))
      end

      def read
        @data = if block_given?
                  yield
                elsif defined?(SiteBuilder) && SiteBuilder.respond_to?(:data_for_id)
                  SiteBuilder.data_for_id(id)
                else
                  raise "No builder exists which can read #{id}"
                end
        @data[:_id_] = id
        @data[:_origin_] = self
        @relative_path = Pathname.new(@data[:_relative_path_]) if @data[:_relative_path_]

        @data
      end

      def exists?
        false
      end
    end
  end
end
