# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    # This class handles custom defaults for front matter settings.
    # It is exposed via the frontmatter_defaults method on the site class.
    class Defaults
      # @return [Bridgetown::Site]
      attr_reader :site

      def initialize(site)
        @site = site
        @defaults_cache = {}
      end

      def reset
        @glob_cache = {}
        @defaults_cache = {}
      end

      def ensure_time!(set)
        return set unless set.key?("values") && set["values"].key?("date")
        return set if set["values"]["date"].is_a?(Time)

        set["values"]["date"] = Utils.parse_date(
          set["values"]["date"],
          "An invalid date format was found in a front-matter default set: #{set}"
        )
        set
      end

      # Collects a hash with all default values for a resource
      #
      # @param path [String] the relative path of the resource
      # @param collection_name [Symbol] :posts, :pages, etc.
      #
      # @return [Hash] all default values (an empty hash if there are none)
      def all(path, collection_name)
        if @defaults_cache.key?([path, collection_name])
          return @defaults_cache[[path, collection_name]]
        end

        defaults = {}
        merge_data_cascade_for_path(path, defaults)

        old_scope = nil
        matching_sets(path, collection_name).each do |set|
          if has_precedence?(old_scope, set["scope"])
            defaults = Utils.deep_merge_hashes(defaults, set["values"])
            old_scope = set["scope"]
          else
            defaults = Utils.deep_merge_hashes(set["values"], defaults)
          end
        end

        @defaults_cache[[path, collection_name]] = defaults
      end

      private

      def merge_data_cascade_for_path(path, merged_data)
        absolute_path = site.in_source_dir(path)
        site.defaults_reader.path_defaults
          .select { |k, _v| absolute_path.include? k }
          .sort_by { |k, _v| k.length }
          .each do |defaults|
          merged_data.merge!(defaults[1])
        end
      end

      # Checks if a given default setting scope matches the given path and collection
      #
      # scope - the hash indicating the scope, as defined in bridgetown.config.yml
      # path - the path to check for
      # collection - the collection (:posts or :pages) to check for
      #
      # Returns true if the scope applies to the given collection and path
      def applies?(scope, path, collection)
        applies_collection?(scope, collection) && applies_path?(scope, path)
      end

      def applies_path?(scope, path)
        rel_scope_path = scope["path"]
        return true if !rel_scope_path.is_a?(String) || rel_scope_path.empty?

        sanitized_path = strip_collections_dir(sanitize_path(path))

        if rel_scope_path.include?("*")
          glob_scope(sanitized_path, rel_scope_path)
        else
          path_is_subpath?(sanitized_path, strip_collections_dir(rel_scope_path))
        end
      end

      def glob_scope(sanitized_path, rel_scope_path)
        site_source    = Pathname.new(site.source)
        abs_scope_path = site_source.join(rel_scope_path).to_s

        glob_cache(abs_scope_path).each do |scope_path|
          scope_path = Pathname.new(scope_path).relative_path_from(site_source).to_s
          scope_path = strip_collections_dir(scope_path)
          Bridgetown.logger.debug "Globbed Scope Path:", scope_path
          return true if path_is_subpath?(sanitized_path, scope_path)
        end
        false
      end

      def glob_cache(path)
        @glob_cache ||= {}
        @glob_cache[path] ||= Dir.glob(path)
      end

      def path_is_subpath?(path, parent_path)
        path.start_with?(parent_path)
      end

      def strip_collections_dir(path)
        collections_dir  = site.config["collections_dir"]
        slashed_coll_dir = collections_dir.empty? ? "/" : "#{collections_dir}/"
        return path if collections_dir.empty? || !path.to_s.start_with?(slashed_coll_dir)

        path.sub(slashed_coll_dir, "")
      end

      # Determines whether the scope applies to collection.
      # The scope applies to the collection if:
      #   1. no 'collection' is specified
      #   2. the 'collection' in the scope is the same as the collection asked about
      #
      # @param scope [Hash] the defaults set being asked about
      # @param collection [Symbol] the collection of the resource being processed
      #
      # @return [Boolean] whether either of the above conditions are satisfied
      def applies_collection?(scope, collection)
        !scope.key?("collection") || scope["collection"].eql?(collection.to_s)
      end

      # Checks if a given set of default values is valid
      #
      # @param set [Hash] the default value hash as defined in bridgetown.config.yml
      #
      # @return [Boolean] if the set is valid and can be used
      def valid?(set)
        set.is_a?(Hash) && set["values"].is_a?(Hash)
      end

      # Determines if a new scope has precedence over an old one
      #
      # old_scope - the old scope hash, or nil if there's none
      # new_scope - the new scope hash
      #
      # Returns true if the new scope has precedence over the older
      # rubocop: disable Naming/PredicateName
      def has_precedence?(old_scope, new_scope)
        return true if old_scope.nil?

        new_path = sanitize_path(new_scope["path"])
        old_path = sanitize_path(old_scope["path"])

        if new_path.length != old_path.length
          new_path.length >= old_path.length
        elsif new_scope.key?("collection")
          true
        else
          !old_scope.key? "collection"
        end
      end
      # rubocop: enable Naming/PredicateName

      # Collects a list of sets that match the given path and collection
      #
      # @return [Array<Hash>]
      def matching_sets(path, collection)
        @matched_set_cache ||= {}
        @matched_set_cache[path] ||= {}
        @matched_set_cache[path][collection] ||= valid_sets.select do |set|
          !set.key?("scope") || applies?(set["scope"], path, collection)
        end
      end

      # Returns a list of valid sets
      #
      # This is not cached to allow plugins to modify the configuration
      # and have their changes take effect
      #
      # @return [Array<Hash>]
      def valid_sets
        sets = site.config["defaults"]
        return [] unless sets.is_a?(Array)

        sets.filter_map do |set|
          if valid?(set)
            massage_scope!(set)
            # TODO: is this trip really necessary?
            ensure_time!(set)
          else
            Bridgetown.logger.warn "Defaults:", "An invalid front-matter default set was found:"
            Bridgetown.logger.warn set.to_s
            nil
          end
        end
      end

      # Set path to blank if not specified and alias older type to collection
      def massage_scope!(set)
        set["scope"] ||= {}
        set["scope"]["path"] ||= ""
        return unless set["scope"]["type"] && !set["scope"]["collection"]

        set["scope"]["collection"] = set["scope"]["type"]
      end

      SANITIZATION_REGEX = %r!\A/|(?<=[^/])\z!

      # Sanitizes the given path by removing a leading and adding a trailing slash
      def sanitize_path(path)
        if path.nil? || path.empty?
          ""
        else
          path.gsub(SANITIZATION_REGEX, "")
        end
      end
    end
  end
end
