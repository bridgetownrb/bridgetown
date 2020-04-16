# frozen_string_literal: true

module Bridgetown
  module Drops
    class CollectionDrop < Drop
      extend Forwardable

      mutable false

      def_delegator  :@obj, :write?, :output
      def_delegators :@obj, :label, :docs, :files, :relative_path

      private def_delegator :@obj, :metadata, :fallback_data

      def to_s
        label
      end
    end
  end
end
