# frozen_string_literal: true

module Bridgetown
  module Routes
    class Manifest
      attr_reader :site, :config, :manifest

      def initialize(site, cache_routes: Bridgetown.env.production?)
        @site = site
        @manifest = []
        @config = site.config.routes
        @cache_routes = cache_routes
        @islands_dir = File.expand_path(site.config.islands_dir, site.config.source)
      end

      def routable_extensions = config.extensions.join(",")

      def routes
        return @manifest if !@manifest.empty? && @cache_routes

        @manifest = []

        # Loop through all the directories (`src/_routes`, etc) looking for route files, then
        # sort them and add them to the manifest:
        expand_source_paths_with_islands.each do |routes_dir|
          @manifest += glob_routes(routes_dir).map do |file|
            file_slug, segment_keys = file_slug_and_segments(routes_dir, file)

            # generate localized file slugs
            localized_file_slugs = generate_localized_file_slugs(file_slug)

            [file, localized_file_slugs, segment_keys]
          end.then { sort_routes! _1 }
        end

        @manifest
      end

      def expand_source_paths_with_islands
        # clear out any past islands folders
        config.source_paths.reject! { _1.start_with?(@islands_dir) }

        Dir.glob("#{@islands_dir}/**/routes").each do |route_folder|
          config.source_paths << route_folder
        end

        config.source_paths.map { File.expand_path _1, site.config.source }
      end

      def glob_routes(dir, pattern = "**/*")
        files = Dir.glob("#{dir}/#{pattern}.{#{routable_extensions}}")
        files.reject! do |file|
          File.basename(file, ".*").then { _1.start_with?("_", ".") || _1.end_with?(".test") }
        end
        files
      end

      def file_slug_and_segments(routes_dir, file)
        # @type [String]
        file_slug = file.delete_prefix("#{routes_dir}/").then do |f|
          if routes_dir.start_with?(@islands_dir)
            # convert _islands/foldername/routes/someroute.rb to foldername/someroute.rb
            f = routes_dir.delete_prefix("#{@islands_dir}/").sub(%r!/routes$!, "/") + f
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

      def generate_localized_file_slugs(file_slug)
        site.config.available_locales.map do |locale|
          if locale == site.config.default_locale && !site.config.prefix_default_locale
            file_slug
          else
            "#{locale}/#{file_slug}"
          end
        end
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

      def locale_for(slug)
        possible_locale_segment = slug.split("/").first.to_sym

        if site.config.available_locales.include? possible_locale_segment
          possible_locale_segment
        else
          site.config.default_locale
        end
      end
    end
  end
end
