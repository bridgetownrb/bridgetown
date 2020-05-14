# frozen_string_literal: true

module Bridgetown
  module Site::Content
    # Construct a Hash of Posts indexed by the specified Post attribute.
    #
    # post_attr - The String name of the Post attribute.
    #
    # Examples
    #
    #   post_attr_hash('categories')
    #   # => { 'tech' => [<Post A>, <Post B>],
    #   #      'ruby' => [<Post B>] }
    #
    # Returns the Hash: { attr => posts } where
    #   attr  - One of the values for the requested attribute.
    #   posts - The Array of Posts with the given attr value.
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

    def tags
      post_attr_hash("tags")
    end

    def categories
      post_attr_hash("categories")
    end

    def metadata
      data["site_metadata"] ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    # The Hash payload containing site-wide data.
    #
    # Returns the Hash: { "site" => data } where data is a Hash with keys:
    #   "time"       - The Time as specified in the configuration or the
    #                  current time if none was specified.
    #   "posts"      - The Array of Posts, sorted chronologically by post date
    #                  and then title.
    #   "pages"      - The Array of all Pages.
    #   "html_pages" - The Array of HTML Pages.
    #   "categories" - The Hash of category values and Posts.
    #                  See Site#post_attr_hash for type info.
    #   "tags"       - The Hash of tag values and Posts.
    #                  See Site#post_attr_hash for type info.
    def site_payload
      Drops::UnifiedPayloadDrop.new self
    end
    alias_method :to_liquid, :site_payload

    # The list of collections and their corresponding Bridgetown::Collection instances.
    # If config['collections'] is set, a new instance is created
    # for each item in the collection, a new hash is returned otherwise.
    #
    # Returns a Hash containing collection name-to-instance pairs.
    def collections
      @collections ||= collection_names.each_with_object(
        ActiveSupport::HashWithIndifferentAccess.new
      ) do |name, hsh|
        hsh[name] = Bridgetown::Collection.new(self, name)
      end
    end

    # The list of collection names.
    #
    # Returns an array of collection names from the configuration,
    #   or an empty array if the `collections` key is not set.
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

    # Get all the documents
    #
    # Returns an Array of all Documents
    def documents
      collections.each_with_object(Set.new) do |(_, collection), set|
        set.merge(collection.docs).merge(collection.files)
      end.to_a
    end

    # Get the to be written documents
    #
    # Returns an Array of Documents which should be written
    def docs_to_write
      documents.select(&:write?)
    end

    def posts
      collections["posts"] ||= Collection.new(self, "posts")
    end
  end
end
