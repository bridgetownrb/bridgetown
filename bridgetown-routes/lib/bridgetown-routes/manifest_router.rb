# frozen_string_literal: true

module Bridgetown
  module Routes
    class ManifestRouter < Bridgetown::Rack::Routes
      priority :lowest

      route do |r|
        unless bridgetown_site
          Bridgetown.logger.warn(
            "The `bridgetown_routes` plugin hasn't been configured in the Roda app."
          )
          return
        end

        Bridgetown::Routes::Manifest.generate_manifest(bridgetown_site).each do |route|
          file, file_slug, segment_keys = route

          r.on file_slug do |*segment_values|
            response["X-Bridgetown-SSR"] = "1"
            # eval_route_file caches when Bridgetown.env.production?
            Bridgetown::Routes::CodeBlocks.eval_route_file file, file_slug, @_roda_app

            segment_values.each_with_index do |value, index|
              r.params[segment_keys[index]] ||= value
            end

            route_block = Bridgetown::Routes::CodeBlocks.route_block(file_slug)
            response.instance_variable_set(
              :@_route_file_code, route_block.instance_variable_get(:@_route_file_code)
            ) # could be nil
            @_roda_app.instance_exec(r, &route_block)
          end
        end

        nil
      end
    end
  end
end
