# frozen_string_literal: true

require "faraday/follow_redirects"

module Bridgetown
  module Builders
    module DSL
      module HTTP
        def get(url, headers: {}, parse_json: true, **params)
          body = begin
            connection(parse_json:).get(url, params, headers).body
          rescue Faraday::ParsingError
            Bridgetown.logger.error(
              "Faraday::ParsingError",
              "The response from #{url} did not contain valid JSON"
            )
            nil
          end
          yield body
        end

        def connection(headers: {}, parse_json: true)
          headers["Content-Type"] = "application/json" if parse_json

          Faraday.new(headers:) do |faraday|
            faraday.response :follow_redirects

            if parse_json
              faraday.response :json, parser_options: {
                object_class: HashWithDotAccess::Hash,
              }
            end

            yield faraday if block_given?
          end
        end
      end
    end
  end
end
