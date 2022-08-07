# frozen_string_literal: true

module Bridgetown
  module Routes
    module FlashHashAdditions
      def info
        self["info"]
      end

      def info=(val)
        self["info"] = val
      end

      def alert
        self["alert"]
      end

      def alert=(val)
        self["alert"] = val
      end
    end

    module FlashHashIndifferent
      def []=(key, val)
        @next[key.to_s] = val
      end
    end

    module FlashNowHashIndifferent
      def []=(key, val)
        super(key.to_s, val)
      end

      def [](key)
        super(key.to_s)
      end
    end
  end
end
