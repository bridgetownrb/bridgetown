# frozen_string_literal: true

module Bridgetown
  module Routes
    module Manifest
      class << self
        def routable_extensions
          %w(rb md serb erb)
        end

        def generate_manifest # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          return @route_manifest if @route_manifest && Bridgetown.env.production?

          routes = File.expand_path("src/_routes", Dir.pwd)
          # @type [Array]
          routes_examined = Dir.glob(routes + "/**/*.{#{routable_extensions.join(",")}}").map do |file|
            next if File.basename(file).start_with?("_")

            # @type [String]
            file_slug = file.delete_prefix(routes + "/").then do |f|
              [File.dirname(f), File.basename(f, ".*")].join("/").delete_prefix("./")
            end.delete_suffix("/index")
            segment_keys = []
            file_slug.gsub!(%r{\[([^/]+)\]}) do |_segment|
              segment_keys << Regexp.last_match(1)
              ":#{Regexp.last_match(1)}"
            end

            [file, file_slug, segment_keys]
          end.compact

          routes_examined.sort! do |route_a, route_b|
            # @type [String]
            _, slug_a = route_a
            _, slug_b = route_b

            weight1 = slug_a.count("/") <=> slug_b.count("/")
            if weight1.zero?
              slug_b.count("/:") <=> slug_a.count("/:")
            else
              weight1
            end
          end.reverse!

          @route_manifest = routes_examined
        end
      end
    end
  end
end
