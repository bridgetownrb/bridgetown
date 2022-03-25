# frozen_string_literal: true

module Bridgetown
  module Drops
    class GeneratedPageDrop < Drop
      extend Forwardable

      mutable false

      def_delegators :@obj,
                     :data,
                     :content,
                     :dir,
                     :name,
                     :path,
                     :url,
                     :relative_url,
                     :relative_path,
                     :all_locales

      private def_delegator :@obj, :data, :fallback_data
    end
  end
end
