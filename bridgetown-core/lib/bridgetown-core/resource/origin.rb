# frozen_string_literal: true

module Bridgetown
  module Resource
    class Origin
      # @return [Pathname]
      attr_accessor :relative_path

      # @return [Base]
      attr_accessor :resource

      YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

      class << self
        def data_file_extensions
          %w(.yaml .yml .json .csv .tsv).freeze
        end
      end

      def read(_resource)
        raise "Implement #read in a subclass of Bridgetown::Origin"
      end
    end
  end
end
