# frozen_string_literal: true

module Bridgetown
  module Model
    # Abstract Superclass
    class Origin
      EAGER_LOAD_DESCENDANTS = %i(BuilderOrigin RepoOrigin PluginOrigin).freeze

      # @return [String]
      attr_accessor :id

      # @return [Bridgetown::Site]
      attr_accessor :site

      # @return [Boolean]
      attr_accessor :bare_text

      # You must implement in subclasses
      def self.handle_scheme?(_scheme)
        false
      end

      def initialize(id, site: Bridgetown::Current.site, bare_text: false)
        self.id = id
        self.site = site
        self.bare_text = bare_text
      end

      # You can override in subclass
      def verify_model?(klass)
        collection_name = URI.parse(id).host.chomp(".collection")

        return klass.collection_name.to_s == collection_name if klass.respond_to?(:collection_name)

        klass.name == site.config.inflector.classify(collection_name)
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

    Origin::EAGER_LOAD_DESCENDANTS.each { const_get _1 }
  end
end
