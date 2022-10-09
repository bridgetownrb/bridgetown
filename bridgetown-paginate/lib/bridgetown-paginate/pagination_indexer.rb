# frozen_string_literal: true

module Bridgetown
  module Paginate
    #
    # Performs indexing of the posts or collection documents as well as
    # filtering said collections when requested by the defined filters.
    #
    class PaginationIndexer
      @cached_index = {}.compare_by_identity

      class << self
        attr_accessor :cached_index
      end

      #
      # Create a hash index for all documents based on a key in the
      # document.data table
      #
      def self.index_documents_by(all_documents, index_key) # rubocop:todo Metrics/AbcSize
        return nil if all_documents.nil?
        return all_documents if index_key.nil?

        # Where queries are a key/value pair, so grab the first key element
        index_key = index_key[0] if index_key.is_a?(Array)

        if (found_index = cached_index.dig(all_documents.object_id, index_key))
          return found_index
        end

        index = {}
        all_documents.each do |document|
          next if document.data.nil?
          next unless document.data.key?(index_key)
          next if document.data[index_key].nil?
          next if document.data[index_key].size <= 0
          next if document.data[index_key].to_s.strip.empty?

          # Only tags and categories come as premade arrays, locale does not,
          # so convert any data elements that are strings into arrays
          document_data = document.data[index_key]
          document_data = document_data.split(%r!;|,!) if document_data.is_a?(String)

          Array(document_data).each do |key|
            key = key.to_s.downcase.strip
            # If the key is a delimitered list of values
            # (meaning the user didn't use an array but a string with commas)
            key.split(%r!;|,!).each do |k_split|
              k_split = k_split.to_s.downcase.strip # Clean whitespace and junk
              index[k_split.to_s] = [] unless index.key?(k_split)
              index[k_split.to_s] << document
            end
          end
        end

        cached_index[all_documents] = {} unless cached_index[all_documents].is_a?(Hash)
        cached_index[all_documents][index_key] = index
        index
      end

      #
      # Creates an intersection (only returns common elements)
      # between multiple arrays
      #
      def self.intersect_arrays(first, *rest)
        return nil if first.nil?
        return nil if rest.nil?

        intersect = first
        rest.each do |item|
          return [] if item.nil?

          intersect &= item
        end

        intersect
      end

      # Filters documents based on a keyed source_documents hash of indexed
      # documents and performs a intersection of the two sets. Returns only
      # documents that are common between all collections
      def self.read_config_value_and_filter_documents(
        config,
        config_key,
        documents,
        source_documents
      )
        return nil if documents.nil?

        # If the source is empty then simply don't do anything
        return nil if source_documents.nil?

        return documents if config.nil?
        return documents unless config.key?(config_key)
        return documents if config[config_key].nil?

        # Get the filter values from the config (this is the cat/tag/locale
        # values that should be filtered on)
        config_value = config[config_key]

        # Use the second key/value element if it's a "where query"
        config_value = config_value[1] if config_key == "where_query"

        # If we're dealing with a delimitered string instead of an array then
        # let's be forgiving
        config_value = config_value.split(%r!;|,!) if config_value.is_a?(String)

        # Now for all filter values for the config key, let's remove all items
        # from the documents that aren't common for all collections that the
        # user wants to filter on
        # TODO: right now this is an "AND" operation if multiple keys are present.
        # Should offer the ability to do an OR operation instead.
        config_value.each do |key|
          key = key.to_s.downcase.strip
          documents = PaginationIndexer.intersect_arrays(documents, source_documents[key])
        end

        # The fully filtered final document list
        documents
      end
    end
  end
end
