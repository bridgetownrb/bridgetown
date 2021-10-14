# frozen_string_literal: true

# See bottom of file for specific origin requires...

module Bridgetown
  module Model
    # Abstract Superclass
    class Origin
      extend ActiveSupport::DescendantsTracker

      # @return [String]
      attr_accessor :id

      # Override in subclass
      def self.handle_scheme?(_scheme)
        false
      end

      def initialize(id)
        self.id = id
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
