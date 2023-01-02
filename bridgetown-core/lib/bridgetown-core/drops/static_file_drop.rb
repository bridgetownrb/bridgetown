# frozen_string_literal: true

module Bridgetown
  module Drops
    class StaticFileDrop < Drop
      extend Forwardable
      def_delegators :@obj, :name, :extname, :date, :modified_time, :basename
      def_delegator :@obj, :relative_path, :path
      def_delegator :@obj, :type, :collection

      private def_delegator :@obj, :data, :fallback_data
    end
  end
end
