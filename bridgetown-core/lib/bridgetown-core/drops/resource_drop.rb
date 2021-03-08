# frozen_string_literal: true

module Bridgetown
  module Drops
    class ResourceDrop < Drop
      extend Forwardable

      NESTED_OBJECT_FIELD_BLACKLIST = %w(
        content output excerpt next previous
      ).freeze

      mutable false

      def_delegator :@obj, :relative_path, :path
      def_delegators :@obj,
                     :id,
                     :output,
                     :content,
                     :to_s,
                     :absolute_url,
                     :relative_path,
                     :relative_url,
                     :date,
                     :taxonomies

      private def_delegator :@obj, :data, :fallback_data

      def collection
        @collection ||= @obj.collection.to_liquid
      end

      def excerpt
        fallback_data["excerpt"].to_s
      end

      def url
        @obj.relative_url
      end

      def <=>(other)
        return nil unless other.is_a? DocumentDrop

        cmp = self["date"] <=> other["date"]
        cmp = self["path"] <=> other["path"] if cmp.nil? || cmp.zero?
        cmp
      end

      def previous
        @previous ||= @obj.previous_doc.to_liquid
      end

      def next
        @next ||= @obj.next_doc.to_liquid
      end

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
    end
  end
end
