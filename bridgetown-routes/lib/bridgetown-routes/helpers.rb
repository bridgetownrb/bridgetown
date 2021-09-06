# frozen_string_literal: true

module Bridgetown
  module Routes
    module ViewHelpers
      def request
        view.resource&.roda_data&.request
      end
      alias_method :r, :request

      def response
        view.resource&.roda_data&.response
      end

      def flash
        view.resource&.roda_data&.flash
      end

      # def csrf_tag(...)
      #   request.scope.csrf_tag(...)
      # end

      # def csrf_token(...)
      #   request.scope.csrf_token(...)
      # end

      def output(type = nil)
        content = yield

        case type
        when :json
          response["content-type"] = "application/json"
          content.to_json
        else
          content
        end
      end
    end
  end
end

Bridgetown::RubyTemplateView::Helpers.include Bridgetown::Routes::ViewHelpers
