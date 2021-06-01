# frozen_string_literal: true

module Bridgetown
  module Drops
    class RelationsDrop < Drop
      mutable false

      def [](type)
        return nil unless type.to_s.in?(@obj.relation_types)

        @obj.resources_for_type(type)
      end

      def key?(type)
        type.to_s.in?(@obj.relation_types)
      end

      def fallback_data
        {}
      end
    end
  end
end
