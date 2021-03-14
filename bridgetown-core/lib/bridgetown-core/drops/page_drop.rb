# frozen_string_literal: true

module Bridgetown
  module Drops
    class PageDrop < Drop
      extend Forwardable

      mutable false

      def_delegators :@obj, :content, :dir, :name, :path, :url, :pager
      private def_delegator :@obj, :data, :fallback_data

      def relative_url
        @obj.relative_url
      end
    end
  end
end
