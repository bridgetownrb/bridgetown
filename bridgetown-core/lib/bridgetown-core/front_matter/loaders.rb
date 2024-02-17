# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module Loaders
      autoload :Base, "bridgetown-core/front_matter/loaders/base"
      autoload :Ruby, "bridgetown-core/front_matter/loaders/ruby"
      autoload :YAML, "bridgetown-core/front_matter/loaders/yaml"

      Result = Struct.new(:content, :front_matter, :line_count, keyword_init: true)

      # Constructs a list of possible loaders for a {Model::RepoOrigin} or {Layout}
      #
      # @param origin_or_layout [Bridgetown::Model::RepoOrigin, Bridgetown::Layout]
      # @return [Array<Loaders::Base>]
      def self.for(origin_or_layout)
        registry.map { |loader_class| loader_class.new(origin_or_layout) }
      end

      # Determines whether a given file has front matter
      #
      # @param path [Pathname, String] the path to the file
      # @return [Boolean] true if the file has front matter, false otherwise
      def self.front_matter?(file)
        registry.any? { |loader_class| loader_class.header?(file) }
      end

      # Registers a new type of front matter loader
      #
      # @param loader_class [Loader::Base]
      # @return [void]
      def self.register(loader_class)
        registry.push(loader_class)
      end

      private_class_method def self.registry
        @registry ||= []
      end

      register YAML
      register Ruby
    end
  end
end
