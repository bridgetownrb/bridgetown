# frozen_string_literal: true

require "faraday_middleware/redirect_limit_reached"
require "faraday_middleware/response/follow_redirects"
require "faraday_middleware/response/parse_json"

module Bridgetown
  module Builders
    module DSL
      module HTTP
        def get(url, headers: {}, parse_json: true)
          body = begin
                   connection(parse_json: parse_json).get(url, headers: headers).body
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

          Faraday.new(headers: headers) do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.use FaradayMiddleware::ParseJson if parse_json
            yield faraday if block_given?
          end
        end
      end
    end
  end
end
