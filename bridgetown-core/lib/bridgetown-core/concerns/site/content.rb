# frozen_string_literal: true

module Bridgetown
  module Site::Content
    # Construct a Hash of Posts indexed by the specified Post attribute.
    #
    # @param post_attr [String] The String name of the Post attribute.
    #
    # @example
    #   Returns a hash like so: { attr => posts } where
    #
    #   attr  - One of the values for the requested attribute.
    #
    #   posts - The Array of Posts with the given attr value.
    #
    # @example
    #
    #   post_attr_hash('categories')
    #   # => { 'tech' => [<Post A>, <Post B>],
    #   #      'ruby' => [<Post B>] }
    #
    # @return [Hash{String, Symbol => Array<Post>}]
    #   Returns a hash of !{attr => posts}
    #
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

    # Returns a hash of "tags" using {#post_attr_hash} where each tag is a key
    # and each value is a post which contains the key.
    # @example
    #   tags
    #   # => { 'tech': [<Post A>, <Post B>],
    #   #      'ruby': [<Post C> }
    # @return [Hash{String, Array<Post>}] Returns a hash of all tags and their corresponding posts
    # @see post_attr_hash
    def tags
      post_attr_hash("tags")
    end

    # Returns a hash of "categories" using {#post_attr_hash} where each tag is
    # a key and each value is a post which contains the key.
    # @example
    #   categories
    #   # => { 'tech': [<Post A>, <Post B>],
    #   #      'ruby': [<Post C> }
    # @return [Hash{String, Array<Post>}] Returns a hash of all categories and
    #   their corresponding posts
    # @see post_attr_hash
    def categories
      post_attr_hash("categories")
    end

    # Returns the value of +data+["site_metadata"] or creates a new instance of
    # +HashWithDotAccess::Hash+
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
      Drops::UnifiedPayloadDrop.new self
    end
    alias_method :to_liquid, :site_payload

    # The list of {#collections} and their corresponding {Bridgetown::Collection} instances.
    #
    # If +config+['collections'] is set, a new instance of {Bridgetown::Collection} is created
    # for each entry in the collections configuration.
    #
    # If +config+["collections"] is not specified, a blank hash is returned.
    #
    # @return [Hash{String, Symbol => Bridgetown::Collection}] A Hash
    #   containing a collection name-to-instance pairs.
    #
    # @return [Hash] Returns a blank hash if no items found
    # @see Collection
    def collections
      @collections ||= collection_names.each_with_object(
        HashWithDotAccess::Hash.new
      ) do |name, hsh|
        hsh[name] = Bridgetown::Collection.new(self, name)
      end
    end

    # An array of collection names.
    # @return [Array<Collection>] an array of collection names from the configuration,
    #   or an empty array if the +config+["collections"] key is not set.
    # @raise ArgumentError Raise an error if +config+["collections"] is not
    #   an Array or a Hash
    def collection_names
      case config["collections"]
      when Hash
        config["collections"].keys
      when Array
        config["collections"]
      when nil
        []
      else
        raise ArgumentError, "Your `collections` key must be a hash or an array."
      end
    end

    # Get all documents.
    # @return [Array<String>] an array of documents from the configuration
    def documents
      collections.each_with_object(Set.new) do |(_, collection), set|
        set.merge(collection.docs).merge(collection.files)
      end.to_a
    end

    # Get the documents to be written
    #
    # @return [Array<String, File>] an Array of Documents which should be written and
    #   that +respond_to :write?+
    # @see #documents
    # @see Collection
    def docs_to_write
      documents.select(&:write?)
    end

    # Get all posts.
    #
    # @return [Collection] A #Collection of posts. Returns +#collections+["posts"]
    # @return [Collection] Return a new #Collection if +#collections+["posts"] is nil
    # @see Collection
    def posts
      collections["posts"] ||= Collection.new(self, "posts")
    end
  end
end
