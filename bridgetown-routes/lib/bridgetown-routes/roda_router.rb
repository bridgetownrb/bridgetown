# frozen_string_literal: true

module Bridgetown
  module Routes
    module RodaRouter
      def self.start!(app)
        r = app.request
        response = app.response

        Bridgetown::Routes::Manifest.generate_manifest.each do |route|
          file, file_slug, segment_keys = route

          r.on file_slug do |*segment_values|
            response["X-Bridgetown-SSR"] = "1"
            # eval_route_file caches when Bridgetown.env.production?
            Bridgetown::Routes::CodeBlocks.eval_route_file file, file_slug, app

            segment_values.each_with_index do |value, index|
              r.params[segment_keys[index]] ||= value
            end

            route_block = Bridgetown::Routes::CodeBlocks.route_block(file_slug)
            response.instance_variable_set(
              :@_route_file_contents, route_block.instance_variable_get(:@_route_file_contents)
            ) # could be nil
            app.instance_exec(r, &route_block)
          end
        end

        nil
      end
    end
  end
end
