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

module Bridgetown
  module Routes
    class BlankFlash < Hash
      include Bridgetown::Routes::FlashHashAdditions

      def now
        self
      end
    end

    module ViewHelpers
      def request
        view.resource&.roda_app&.request
      end
      alias_method :r, :request

      def response
        view.resource&.roda_app&.response
      end

      def flash
        view.resource&.roda_app&.flash || _basic_flash
      end

      def _basic_flash
        @_basic_flash ||= BlankFlash.new
      end

      # def csrf_tag(...)
      #   request.scope.csrf_tag(...)
      # end

      # def csrf_token(...)
      #   request.scope.csrf_token(...)
      # end
    end
  end
end

Bridgetown::RubyTemplateView::Helpers.include Bridgetown::Routes::ViewHelpers
