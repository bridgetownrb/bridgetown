# frozen_string_literal: true

module Bridgetown
  module Routes
    module ViewHelpers
      # This flash is only used as a stub for views in case there's no Roda flash
      # available in the rendering context
      class Flash < Hash
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

        def now
          self
        end
      end

      def roda_app
        view.resource&.roda_app
      end

      def request
        roda_app&.request
      end
      alias_method :r, :request

      def response
        roda_app&.response
      end

      def flash
        roda_app&.flash || _blank_flash
      end

      def _blank_flash
        @_blank_flash ||= Flash.new
      end

      def csrf_tag(...)
        roda_app.csrf_tag(...).html_safe
      end

      def csrf_token(...)
        roda_app.csrf_token(...).html_safe
      end
    end
  end
end

Bridgetown::RubyTemplateView::Helpers.include Bridgetown::Routes::ViewHelpers
