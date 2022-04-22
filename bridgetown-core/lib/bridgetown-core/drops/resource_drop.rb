# frozen_string_literal: true

module Bridgetown
  module Drops
    class ResourceDrop < Drop
      extend Forwardable

      NESTED_OBJECT_FIELD_BLACKLIST = %w(
        content output excerpt next previous next_resource previous_resource
      ).freeze

      mutable false

      def_delegators :@obj,
                     :id,
                     :data,
                     :output,
                     :content,
                     :summary,
                     :to_s,
                     :absolute_url,
                     :path,
                     :relative_path,
                     :relative_url,
                     :date,
                     :taxonomies,
                     :relations,
                     :all_locales

      private def_delegator :@obj, :data, :fallback_data

      def collection
        @collection ||= @obj.collection.to_liquid
      end

      def relative_path
        @relative_path ||= @obj.relative_path.to_s
      end

      def <=>(other)
        return nil unless other.is_a? ResourceDrop

        cmp = self["date"] <=> other["date"]
        cmp = self["path"] <=> other["path"] if cmp.nil? || cmp.zero?
        cmp
      end

      def next_resource
        @next ||= @obj.next_resource.to_liquid
      end
      alias_method :next, :next_resource

      def previous_resource
        @previous ||= @obj.previous_resource.to_liquid
      end
      alias_method :previous, :previous_resource

      # Generate a Hash for use in generating JSON.
      # This is useful if fields need to be cleared before the JSON can generate.
      #
      # state - the JSON::State object which determines the state of current processing.
      #
      # Returns a Hash ready for JSON generation.
      def hash_for_json(state = nil)
        to_h.tap do |hash|
          # use collection label in the hash
          hash["collection"] = hash["collection"]["label"] if hash["collection"]

          if state && state.depth >= 2
            hash["previous"] = collapse_document(hash["previous"]) if hash["previous"]
            hash["next"]     = collapse_document(hash["next"]) if hash["next"]
          end
        end
      end

      # Generate a Hash which breaks the recursive chain.
      # Certain fields which are normally available are omitted.
      #
      # Returns a Hash with only non-recursive fields present.
      def collapse_document(doc)
        doc.keys.each_with_object({}) do |(key, _), result|
          result[key] = doc[key] unless NESTED_OBJECT_FIELD_BLACKLIST.include?(key)
        end
      end

      # Generates a list of keys with user content as their values.
      # This gathers up the Drop methods and keys of the mutations and
      # underlying data hashes and performs a set union to ensure a list
      # of unique keys for the Drop.
      #
      # @return [Array<String>]
      def keys
        keys_to_remove = %w[next_resource previous_resource]
        (content_methods |
          mutations.keys |
          fallback_data.keys).flatten.reject do |key|
          keys_to_remove.include?(key)
        end
      end

      # Inspect the drop's keys and values through a JSON representation
      # of its keys and values.
      def inspect
        JSON.pretty_generate hash_for_json
      end
    end
  end
end
