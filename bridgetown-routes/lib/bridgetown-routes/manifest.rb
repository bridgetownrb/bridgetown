# frozen_string_literal: true

module Bridgetown
  module Routes
    module Manifest
      class << self
        # TODO: make this extensible
        def routable_extensions
          %w(rb md serb erb liquid)
        end

        def generate_manifest(site) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          return @route_manifest[site.label] if @route_manifest && Bridgetown.env.production?

          routes_dir = site.in_source_dir("_routes")
          # @type [Array]
          routes = Dir.glob(
            routes_dir + "/**/*.{#{routable_extensions.join(",")}}"
          ).filter_map do |file|
            if File.basename(file).start_with?("_", ".") ||
                File.basename(file, ".*").end_with?(".test")
              next
            end

            # @type [String]
            file_slug = file.delete_prefix("#{routes_dir}/").then do |f|
              [File.dirname(f), File.basename(f, ".*")].join("/").delete_prefix("./")
            end.delete_suffix("/index")
            segment_keys = []
            file_slug.gsub!(%r{\[([^/]+)\]}) do |_segment|
              segment_keys << Regexp.last_match(1)
              ":#{Regexp.last_match(1)}"
            end

            [file, file_slug, segment_keys]
          end

          routes.sort! do |route_a, route_b|
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

          @route_manifest ||= {}
          @route_manifest[site.label] = routes
        end
      end
    end
  end
end
