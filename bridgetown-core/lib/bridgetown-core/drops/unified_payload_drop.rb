# frozen_string_literal: true

module Bridgetown
  module Drops
    class UnifiedPayloadDrop < Drop
      mutable true

      attr_accessor :page, :layout, :content, :paginator
      alias_method :resource, :page

      def bridgetown
        BridgetownDrop.global
      end

      def site
        @site_drop ||= SiteDrop.new(@obj)
      end

      def collections
        @obj.collections
      end

      private

      def fallback_data
        @fallback_data ||= {}
      end
    end
  end
end
