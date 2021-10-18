# frozen_string_literal: true

module Bridgetown
  module Routes
    module ViewHelpers
      def request
        view.resource&.roda_app&.request
      end
      alias_method :r, :request

      def response
        view.resource&.roda_app&.response
      end

      def flash
        view.resource&.roda_app&.flash
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
