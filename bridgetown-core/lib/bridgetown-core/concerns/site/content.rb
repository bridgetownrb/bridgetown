# frozen_string_literal: true

class Bridgetown::Site
  # Content is king!
  module Content
    # Construct a Hash of Posts indexed by the specified Post attribute.
    #
    # Returns a hash like so: `{ attr => posts }` where:
    #
    # * `attr` - One of the values for the requested attribute.
    # * `posts` - The array of Posts with the given attr value.
    #
    # @param post_attr [String] The String name of the Post attribute.
    #
    # @example
    #   post_attr_hash('categories')
    #   # => { 'tech' => [<Post A>, <Post B>],
    #   #      'ruby' => [<Post B>] }
    #
    # @return [Hash{String, Symbol => Array<Post>}]
    #   Returns a hash of !{attr => posts}
    def post_attr_hash(post_attr)
      # Build a hash map based on the specified post attribute ( post attr =>
      # array of posts ) then sort each array in reverse order.
      @post_attr_hash[post_attr] ||= begin
        hash = Hash.new { |h, key| h[key] = [] }
        posts.docs.each do |p|
          p.data[post_attr]&.each { |t| hash[t] << p }
        end
        hash.each_value { |posts| posts.sort!.reverse! }
        hash
      end
    end

    def resources_grouped_by_taxonomy(taxonomy)
      @post_attr_hash[taxonomy.label] ||= begin
        taxonomy.terms.transform_values { |terms| terms.map(&:resource).sort.reverse }
      end
    end

    def taxonomies
      taxonomy_types.transform_values do |taxonomy|
        resources_grouped_by_taxonomy(taxonomy)
      end
    end

    # Returns a hash of "tags" using {#post_attr_hash} where each tag is a key
    #  and each value is a post which contains the key.
    # @example
    #   tags
    #   # => { 'tech': [<Post A>, <Post B>],
    #   #      'ruby': [<Post C> }
    # @return [Hash{String, Array<Post>}] Returns a hash of all tags and their corresponding posts
    # @see post_attr_hash
    def tags
      uses_resource? ? taxonomies.tag : post_attr_hash("tags")
    end

    # Returns a hash of "categories" using {#post_attr_hash} where each tag is
    #  a key and each value is a post which contains the key.
    # @example
    #   categories
    #   # => { 'tech': [<Post A>, <Post B>],
    #   #      'ruby': [<Post C> }
    # @return [Hash{String, Array<Post>}] Returns a hash of all categories and
    #   their corresponding posts
    # @see post_attr_hash
    def categories
      uses_resource? ? taxonomies.category : post_attr_hash("categories")
    end

    # Returns the value of `data["site_metadata"]` or creates a new instance of
    #   `HashWithDotAccess::Hash`
    # @return [Hash] Returns a hash of site metadata
    def metadata
      data["site_metadata"] ||= HashWithDotAccess::Hash.new
    end

    # The Hash payload containing site-wide data.
    #
    # @example
    #   site_payload
    #   # => { "site" => data } Where data is a Hash. See example below
    #
    #   site = site_payload["site"]
    #   # => Returns a Hash with the following keys:
    #   #
    #   # site["time"]       - The Time as specified in the configuration or the
    #   #                      current time if none was specified.
    #   #
    #   # site["posts"]      - The Array of Posts, sorted chronologically by post date
    #   #                      and then title.
    #   #
    #   # site["pages"]      - The Array of all Pages.
    #   #
    #   # site["html_pages"] - The Array of HTML Pages.
    #   #
    #   # site["categories"] - The Hash of category values and Posts.
    #   #                      See Site#post_attr_hash for type info.
    #   #
    #   # site["tags"]       - The Hash of tag values and Posts.
    #   #                      See Site#post_attr_hash for type info.
    #
    # @return [Hash] Returns a hash in the structure of { "site" => data }
    #
    #   See above example for usage.
    #
    # @see #post_attr_hash
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
      @taxonomy_types ||= config.taxonomies.map do |label, key_or_metadata|
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
      end.to_h.with_dot_access
    end

    # Get all documents.
    # @return [Array<Document>] an array of documents from the
    # configuration
    def documents
      collections.each_with_object(Set.new) do |(_, collection), set|
        set.merge(collection.docs)
      end.to_a
    end

    # Get the documents to be written
    #
    # @return [Array<Document>] an array of documents which should be
    #   written and that `respond_to :write?`
    # @see #documents
    # @see Collection
    def docs_to_write
      documents.select(&:write?)
    end

    # Get all loaded resources.
    # @return [Array<Bridgetown::Resource::Base>] an array of resources
    def resources
      collections.each_with_object(Set.new) do |(_, collection), set|
        set.merge(collection.resources)
      end.to_a
    end

    def resources_to_write
      resources.select(&:write?)
    end

    # Get all posts. Deprecated, to be removed in v1.0.
    #
    # @return [Collection] Returns {#collections}`["posts"]`, creating it if need be
    # @see Collection
    def posts
      unless @wrote_deprecation_msg
        Bridgetown::Deprecator.deprecation_message "Call site.collections.posts " \
                                                   "instead of site.posts (Ruby code)"
      end
      @wrote_deprecation_msg ||= true
      collections["posts"] ||= Bridgetown::Collection.new(self, "posts")
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

    # Get all pages and documents (posts and collection items) in a single array.
    #
    # @return [Array]
    def contents
      return resources if uses_resource?

      pages + documents
    end

    def add_generated_page(generated_page)
      generated_pages << generated_page
    end

    # Loads and memoizes the parsed Webpack manifest file (if available)
    # @return [Hash]
    def frontend_manifest
      @frontend_manifest ||= begin
        manifest_file = in_root_dir(".bridgetown-webpack", "manifest.json")

        JSON.parse(File.read(manifest_file)) if File.exist?(manifest_file)
      end
    end
  end
end
