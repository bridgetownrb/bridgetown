# frozen_string_literal: true

module Bridgetown
  module Drops
    class RelationsDrop < Drop
      mutable false

      def [](type)
        p "type?", type
        return nil unless type.to_s.in?(@obj.relation_types)

        p "type!"
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
