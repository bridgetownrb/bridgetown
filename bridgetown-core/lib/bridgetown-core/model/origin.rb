# frozen_string_literal: true

# See bottom of file for specific origin requires...

module Bridgetown
  module Model
    # Abstract Superclass
    class Origin
      extend ActiveSupport::DescendantsTracker

      # @return [String]
      attr_accessor :id

      # You must implement in subclasses
      def self.handle_scheme?(_scheme)
        false
      end

      def initialize(id)
        self.id = id
      end

      # You can override in subclass
      def verify_model?(klass)
        collection_name = URI.parse(id).host.chomp(".collection")

        return klass.collection_name.to_s == collection_name if klass.respond_to?(:collection_name)

        klass.name == ActiveSupport::Inflector.classify(collection_name)
      end

      def read
        raise "Implement #read in a subclass of Bridgetown::Model::Origin"
      end

      # @return [Pathname]
      def relative_path
        raise "Implement #relative_path in a subclass of Bridgetown::Model::Origin"
      end

      def exists?
        raise "Implement #exists? in a subclass of Bridgetown::Model::Origin"
      end
    end
  end
end

require "bridgetown-core/model/builder_origin"
require "bridgetown-core/model/repo_origin"
require "bridgetown-core/model/plugin_origin"
