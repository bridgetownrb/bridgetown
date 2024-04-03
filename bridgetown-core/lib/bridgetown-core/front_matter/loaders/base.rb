# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module Loaders
      # An abstract base class for processing front matter
      class Base
        # @param origin_or_layout [Bridgetown::Model::RepoOrigin, Bridgetown::Layout]
        def initialize(origin_or_layout)
          @origin_or_layout = origin_or_layout
        end

        # Reads the contents of a file, returning a possible {Result}
        #
        # @param file_contents [String] the contents of the file being processed
        # @param file_path [String] the path to the file being processed
        # @return [Result, nil]
        def read(file_contents, file_path:) # rubocop:disable Lint/UnusedMethodArgument
          raise "Implement #read in a subclass of Bridgetown::FrontMatter::Loaders::Base"
        end

        private

        # @return [Bridgetown::Model::RepoOrigin, Bridgetown::Layout]
        attr_reader :origin_or_layout
      end
    end
  end
end
