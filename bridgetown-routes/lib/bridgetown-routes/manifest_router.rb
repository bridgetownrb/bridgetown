# frozen_string_literal: true

require "bridgetown-core/rack/routes"

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
          file, localized_file_slugs, segment_keys = route

          localized_file_slugs.each do |file_slug|
            add_route(r, file, file_slug, segment_keys)
          end
        end

        nil
      end

      private

      def add_route(route, file, file_slug, segment_keys)
        route.on file_slug do |*segment_values|
          response["X-Bridgetown-SSR"] = "1"
          # eval_route_file caches when Bridgetown.env.production?
          Bridgetown::Routes::CodeBlocks.eval_route_file file, file_slug, @_roda_app

          segment_values.each_with_index do |value, index|
            route.params[segment_keys[index]] ||= value
          end

          # set route locale
          locale = Bridgetown::Routes::Manifest.locale_for(file_slug, bridgetown_site)
          I18n.locale           = locale
          route.params[:locale] = locale

          route_block = Bridgetown::Routes::CodeBlocks.route_block(file_slug)
          response.instance_variable_set(
            :@_route_file_code, route_block.instance_variable_get(:@_route_file_code)
          ) # could be nil
          @_roda_app.instance_exec(route, &route_block)
        end
      end
    end
  end
end
