# frozen_string_literal: true

class Bridgetown::Site
  # Content is king!
  module Content
    def resources_grouped_by_taxonomy(taxonomy)
      data.site_taxonomies_hash ||= {}
      data.site_taxonomies_hash[taxonomy.label] ||= taxonomy.terms.transform_values do |terms|
        terms.map(&:resource).sort.reverse
      end
    end

    def taxonomies
      taxonomy_types.transform_values do |taxonomy|
        resources_grouped_by_taxonomy(taxonomy)
      end
    end

    def tags
      taxonomies.tag
    end

    def categories
      taxonomies.category
    end

    # Returns the value of `data["site_metadata"]` or creates a new instance of
    #   `HashWithDotAccess::Hash`
    # @return [Hash] Returns a hash of site metadata
    def metadata
      data["site_metadata"] ||= HashWithDotAccess::Hash.new
    end

    # The Hash payload containing site-wide data.
    #
    # @return [Hash] Returns a hash in the structure of { "site" => data }
    def site_payload
      Bridgetown::Drops::UnifiedPayloadDrop.new self
    end
    alias_method :to_liquid, :site_payload

    # The list of collections labels and their corresponding {Collection} instances.
    #
    #  If `config['collections']` is set, a new instance of {Collection} is created
    #  for each entry in the collections configuration.
    #
    #  If `config["collections"]` is not specified, a blank hash is returned.
    #
    # @return [Hash{String, Symbol => Collection}] A Hash
    #   containing a collection name-to-instance pairs.
    #
    # @return [Hash] Returns a blank hash if no items found
    def collections
      @collections ||= collection_names.each_with_object(
        HashWithDotAccess::Hash.new
      ) do |name, hsh|
        hsh[name] = Bridgetown::Collection.new(self, name)
      end
    end

    # An array of collection names.
    # @return [Array<String>] an array of collection names from the configuration,
    #   or an empty array if the `config["collections"]` key is not set.
    def collection_names
      Array(config.collections&.keys)
    end

    # @return [Array<Bridgetown::Resource::TaxonomyType>]
    def taxonomy_types
      @taxonomy_types ||= config.taxonomies.to_h do |label, key_or_metadata|
        key = key_or_metadata
        tax_metadata = if key_or_metadata.is_a? Hash
                         key = key_or_metadata["key"]
                         key_or_metadata.reject { |k| k == "key" }
                       else
                         HashWithDotAccess::Hash.new
                       end

        [label, Bridgetown::Resource::TaxonomyType.new(
          site: self, label: label, key: key, metadata: tax_metadata
        ),]
      end.with_dot_access
    end

    # Get all loaded resources.
    # @return [Array<Bridgetown::Resource::Base>] an array of resources
    def resources
      collections.each_with_object(Set.new) do |(_, collection), set|
        set.merge(collection.resources)
      end.to_a
    end

    alias_method :contents, :resources

    def resources_to_write
      resources.select(&:write?)
    end

    # Get the static files to be written
    #
    # @return [Array<StaticFile>] an array of files which should be
    #   written and that `respond_to :write?`
    # @see #static_files
    # @see StaticFile
    def static_files_to_write
      static_files.select(&:write?)
    end

    def add_generated_page(generated_page)
      generated_pages << generated_page
    end

    # Loads and memoizes the parsed frontend bundler manifest file (if available)
    # @return [Hash]
    def frontend_manifest
      @frontend_manifest ||= begin
        manifest_file = File.join(frontend_bundling_path, "manifest.json")

        JSON.parse(File.read(manifest_file)) if File.exist?(manifest_file)
      end
    end
  end
end
