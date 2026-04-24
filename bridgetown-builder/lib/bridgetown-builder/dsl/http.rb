# frozen_string_literal: true

require "faraday/follow_redirects"

module Bridgetown
  module Builders
    module DSL
      module HTTP
        def get(url, headers: {}, parse_json: true, **params)
          Deprecator.deprecation_message(
            "The DSL for HTTP requests (`get`) is deprecated and will be " \
            "removed in Bridgetown 3.0. Use an HTTP client such as HTTPX: " \
            "https://honeyryderchuck.gitlab.io/httpx"
          )
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
          callers = caller_locations.map { [_1.base_label, _1.path] }
          this_file_path = "bridgetown-builder/lib/bridgetown-builder/dsl/http.rb"
          called_from_get = callers.any? do |base_label, path|
            base_label == "get" && path.end_with?(this_file_path)
          end
          unless called_from_get
            Deprecator.deprecation_message(
              "The DSL for HTTP requests (`connection`) is deprecated and will be " \
              "removed in Bridgetown 3.0. Use an HTTP client such as HTTPX: " \
              "https://honeyryderchuck.gitlab.io/httpx"
            )
          end

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
