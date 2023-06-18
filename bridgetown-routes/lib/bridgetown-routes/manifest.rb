# frozen_string_literal: true

module Bridgetown
  module Routes
    module Manifest
      class << self
        def generate_manifest(site) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity
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

              file_slug, segment_keys = file_slug_and_segments(site, routes_dir, file)

              # generate localized file slugs
              localized_file_slugs = generate_localized_file_slugs(site, file_slug)

              [file, localized_file_slugs, segment_keys]
            end

            new_manifest += sort_routes!(routes)
          end

          @route_manifest ||= {}
          @route_manifest[site.label] = new_manifest
        end

        def sort_routes!(routes)
          routes.sort! do |route_a, route_b|
            # @type [String]
            slug_a = route_a[1][0]
            # @type [String]
            slug_b = route_b[1][0]

            # @type [Integer]
            weight1 = slug_a.count("/") <=> slug_b.count("/")
            if weight1.zero?
              slug_b.count("/:") <=> slug_a.count("/:")
            else
              weight1
            end
          end.reverse!
        end

        def locale_for(slug, site)
          possible_locale_segment = slug.split("/").first.to_sym

          if site.config.available_locales.include? possible_locale_segment
            possible_locale_segment
          else
            site.config.default_locale
          end
        end

        private

        def file_slug_and_segments(site, routes_dir, file)
          # @type [String]
          file_slug = file.delete_prefix("#{routes_dir}/").then do |f|
            if routes_dir.start_with?(
              File.expand_path(site.config[:islands_dir], site.config.source)
            )
              f = "#{site.config[:islands_dir].delete_prefix("_")}/#{f}"
            end
            [File.dirname(f), File.basename(f, ".*")].join("/").delete_prefix("./")
          end.delete_suffix("/index")
          segment_keys = []
          file_slug.gsub!(%r{\[([^/]+)\]}) do |_segment|
            segment_keys << Regexp.last_match(1)
            ":#{Regexp.last_match(1)}"
          end

          [file_slug, segment_keys]
        end

        def generate_localized_file_slugs(site, file_slug)
          site.config.available_locales.map do |locale|
            if locale == site.config.default_locale && !site.config.prefix_default_locale
              file_slug
            else
              "#{locale}/#{file_slug}"
            end
          end
        end
      end
    end
  end
end
