# frozen_string_literal: true

module Bridgetown
  module Routes
    module Manifest
      class << self
        def generate_manifest(site) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
          return @route_manifest[site.label] if @route_manifest && Bridgetown.env.production?

          new_manifest = []
          routable_extensions = site.config.routes.extensions.join(",")

          site.config.routes.source_paths.each do |routes_dir|
            routes_dir = File.expand_path(routes_dir, site.config.source)

            # @type [Array]
            routes = Dir.glob(
              routes_dir + "/**/*.{#{routable_extensions}}"
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

            new_manifest += sort_routes!(routes)
          end
          @route_manifest ||= {}
          @route_manifest[site.label] = new_manifest
        end

        def sort_routes!(routes)
          routes.sort! do |route_a, route_b|
            # @type [String]
            _, slug_a = route_a
            # @type [String]
            _, slug_b = route_b

            # @type [Integer]
            weight1 = slug_a.count("/") <=> slug_b.count("/")
            if weight1.zero?
              slug_b.count("/:") <=> slug_a.count("/:")
            else
              weight1
            end
          end.reverse!
        end
      end
    end
  end
end
